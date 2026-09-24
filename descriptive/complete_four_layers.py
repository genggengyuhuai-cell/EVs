"""Complete pre-QC description. No exclusions, imputation or normalization."""
from pathlib import Path
import hashlib
import json
import numpy as np
import pandas as pd
from openpyxl import load_workbook
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from nature_plotting import new_figure, save as save_nature, save_series

OUT=Path(__file__).resolve().parent
ROOT=OUT.parent
audit=json.loads((OUT/'audit.json').read_text(encoding='utf-8'))
for name in ['processed.xlsx','sample_mapping_FINAL.xlsx']:
    assert hashlib.sha256((ROOT/'rawdata'/name).read_bytes()).hexdigest()==audit[name+'_sha256']
s=pd.read_csv(OUT/'sample_statistics.csv',keep_default_na=False).sort_values('Sheet1_position').reset_index(drop=True)
wb=load_workbook(ROOT/'rawdata'/'processed.xlsx',read_only=True,data_only=True)
rows=wb.worksheets[0].iter_rows(values_only=True); header=next(rows)
df=pd.DataFrame(list(rows)); wb.close()
def clean_header(v):
    text=str(v).strip()
    return text[:-2] if text.endswith('.0') else text
assert [clean_header(v) for v in header[7:]]==s.Sheet1_raw_header.tolist()
annotation=df.iloc[:,:7].copy(); annotation.columns=header[:7]
x=df.iloc[:,7:].apply(pd.to_numeric,errors='raise').to_numpy(dtype=float)
valid=np.isfinite(x)&(x>0)
N,n=x.shape
assert (N,n)==(3817,519)
assert np.array_equal(valid.sum(axis=0),s.detected_protein_groups)
assert (~valid).sum()==audit['missing_cells']
obs=pd.DataFrame(np.where(valid,x,np.nan))
s['missing_protein_groups']=N-valid.sum(axis=0)
s['median_observed_abundance']=obs.median(axis=0).to_numpy()
s['total_observed_abundance']=obs.sum(axis=0,min_count=1).to_numpy()
s['mean_observed_abundance']=obs.mean(axis=0).to_numpy()
s['q25_observed_abundance']=obs.quantile(.25,axis=0).to_numpy()
s['q75_observed_abundance']=obs.quantile(.75,axis=0).to_numpy()
s['MS_batch_proxy']=s['进样时间'].astype(str)
s['overall']='Overall'
s.to_csv(OUT/'sample_depth_and_signal.csv',index=False,encoding='utf-8-sig')
thresholds=[1]+list(range(10,101,10)); focus=[50,60,70,80,90]
fields=['overall','condition','group','TREAT1_clean','MS_batch_proxy']
records=[]; counts_by={}; names_by={}; sizes_by={}
p=annotation.copy()
p['overall_detection_rate']=valid.mean(axis=1)
p['mean_observed_abundance']=obs.mean(axis=1).to_numpy()
p['median_observed_abundance']=obs.median(axis=1).to_numpy()
p['missing_pct']=(~valid).mean(axis=1)*100
p['coverage_class']=np.select([valid.sum(axis=1)*100 < 50*n,valid.sum(axis=1)*100 < 80*n,valid.sum(axis=1)*100 < 90*n],['Sparse (<50%)','Moderate (50–<80%)','High (80–<90%)'],default='High (≥90%)')
for field in fields:
    cc=[]; cats=[]; sizes=[]
    for category,sub in s.groupby(field,sort=True,dropna=False):
        counts=valid[:,sub.index].sum(axis=1); nn=len(sub)
        cc.append(counts); cats.append(str(category)); sizes.append(nn)
        p[f'{field}__{category}__detection_rate']=counts/nn
        any_count=int((counts>0).sum())
        previous=N
        for t in thresholds:
            retained=int((counts*100>=t*nn).sum())
            assert retained<=previous; previous=retained
            records.append({'level':field,'category':str(category),'samples':nn,'threshold_pct':t,'minimum_detected_samples':(t*nn+99)//100,'protein_groups':retained,'pct_of_all_protein_groups':retained/N*100,'detected_at_least_one_sample':any_count})
    counts_by[field]=np.array(cc); names_by[field]=cats; sizes_by[field]=np.array(sizes)
long=pd.DataFrame(records)
long.to_csv(OUT/'coverage_all_levels_long.csv',index=False,encoding='utf-8-sig')
wide=long.pivot(index=['level','category','samples','detected_at_least_one_sample'],columns='threshold_pct',values='protein_groups').reset_index()
wide.to_csv(OUT/'coverage_all_levels_wide.csv',index=False,encoding='utf-8-sig')
# Match previous independent gradient implementation, including all boundary cases.
old=pd.read_csv(OUT/'detection_gradient_long.csv')
comparison=old.merge(long,on=['level','category','threshold_pct'],suffixes=('_old','_new'))
assert len(comparison)==len(old)
assert (comparison.protein_groups_old==comparison.protein_groups_new).all()

for t in [50,80,90]:
    p[f'groups_meeting_ge{t}pct']=(counts_by['group']*100>=t*sizes_by['group'][:,None]).sum(axis=0)
    p[f'conditions_meeting_ge{t}pct']=(counts_by['condition']*100>=t*sizes_by['condition'][:,None]).sum(axis=0)
p['global_core_ge80pct']=valid.sum(axis=1)*100>=80*n
p['global_core_ge90pct']=valid.sum(axis=1)*100>=90*n
p['all_groups_ge50pct']=p.groups_meeting_ge50pct==9
p['all_groups_ge80pct']=p.groups_meeting_ge80pct==9
p['all_conditions_ge80pct']=p.conditions_meeting_ge80pct==2
p.to_csv(OUT/'protein_detection_landscape.csv',index=False,encoding='utf-8-sig')
criteria=['global_core_ge80pct','global_core_ge90pct','all_groups_ge50pct','all_groups_ge80pct','all_conditions_ge80pct']
core=pd.DataFrame({'criterion':criteria,'protein_groups':[int(p[c].sum()) for c in criteria]})
core.to_csv(OUT/'core_coverage_counts.csv',index=False,encoding='utf-8-sig')
for c in criteria:
    p.loc[p[c],list(annotation.columns)+['overall_detection_rate','groups_meeting_ge50pct','groups_meeting_ge80pct']].to_csv(OUT/f'proteins_{c}.csv',index=False,encoding='utf-8-sig')
breadth=pd.DataFrame({'groups_meeting_threshold':range(10)})
for t in [50,80,90]: breadth[f'protein_groups_ge{t}pct']=p[f'groups_meeting_ge{t}pct'].value_counts().reindex(range(10),fill_value=0).to_numpy()
assert (breadth.iloc[:,1:].sum()==N).all()
breadth.to_csv(OUT/'cross_group_detection_breadth.csv',index=False,encoding='utf-8-sig')
classes=p.coverage_class.value_counts().rename_axis('coverage_class').reset_index(name='protein_groups')
classes.to_csv(OUT/'global_coverage_classes.csv',index=False,encoding='utf-8-sig')
metric_cols=['detected_protein_groups','missing_protein_groups','missing_pct','median_observed_abundance','total_observed_abundance','mean_observed_abundance']
stats=[]
for field in fields:
    for name,sub in s.groupby(field,sort=True):
        for metric in metric_cols:
            v=sub[metric]
            stats.append({'level':field,'category':name,'samples':len(v),'metric':metric,'median':v.median(),'q25':v.quantile(.25),'q75':v.quantile(.75),'min':v.min(),'max':v.max(),'mean':v.mean()})
pd.DataFrame(stats).to_csv(OUT/'sample_depth_signal_group_summaries.csv',index=False,encoding='utf-8-sig')

plt.rcParams.update({'font.family':'sans-serif','font.sans-serif':['Arial','DejaVu Sans'],'font.size':7,'axes.titlesize':8,'axes.labelsize':7,'xtick.labelsize':6,'ytick.labelsize':6,'legend.fontsize':6,'svg.fonttype':'none','pdf.fonttype':42,'axes.spines.top':False,'axes.spines.right':False})
def save(fig,name):
    save_nature(fig, OUT, name)
def panel(ax,letter,title):
    ax.set_title(title,loc='left',pad=8)
palette=['#527D9E','#C48C59','#69958A','#957B9B','#7E8790','#A18E57']
styles=['-','--','-.',':','-','--']; markers=['o','s','^','D','v','P']
coverage_figures, coverage_axes = zip(*(new_figure() for _ in range(4)))
axs = np.array(coverage_axes, dtype=object)
curve_sets=[long[long.level.isin(['overall','condition'])],long[long.level=='TREAT1_clean'],long[(long.level=='MS_batch_proxy')&long.category.str.startswith('2025')],long[(long.level=='MS_batch_proxy')&long.category.str.startswith('2026')]]
titles=['Overall and environments','TREAT1 (all labels retained)','Run dates in 2025 (batch proxies)','Run dates in 2026 (batch proxies)']
displays={'high_stress':'High stress','high_temperature':'High temperature','control':'Control','low':'Short exposure','high':'Long exposure','unknown':'Unknown','missing':'Missing'}
semantic_colors={'Overall':'#50575E','high_stress':'#527D9E','high_temperature':'#C48C59','control':'#929AA2','low':'#79A9BC','high':'#335C7B','unknown':'#CAA369','missing':'#A7ADB2'}
for j,(ax,sub,title) in enumerate(zip(axs.ravel(),curve_sets,titles)):
    for i,(name,d) in enumerate(sub[sub.threshold_pct>=10].groupby('category')):
        ax.plot(d.threshold_pct,d.protein_groups,color=semantic_colors.get(name,palette[i]),linestyle=styles[i],marker=markers[i],ms=3,lw=1,label=f'{displays.get(name,name)} (n={d.samples.iloc[0]})')
    ax.set_xlim(8,102);ax.set_ylim(0,4400);ax.set_xticks([10,30,50,70,90,100]);ax.set_xlabel('Detection threshold (%)');ax.set_ylabel('Protein groups meeting threshold')
    ax.legend(frameon=False,loc='upper right',ncol=2,fontsize=5.5)
    panel(ax,'abcd'[j],title)
save_series(coverage_figures, OUT, ['Figure6_coverage_other_levels', 'Figure6_coverage_exposure',
                                   'Figure6_coverage_dates_2025', 'Figure6_coverage_dates_2026'])

for fnum,field,title in [(7,'condition','Environment'),(8,'group','Group'),(9,'TREAT1_clean','TREAT1'),(10,'MS_batch_proxy','Run date (batch proxy)')]:
    groups=list(s.groupby(field,sort=True))
    if field=='TREAT1_clean': groups=sorted(groups,key=lambda it:['control','low','high','unknown','missing'].index(it[0]))
    metric_figures, metric_axes = zip(*(new_figure(183, max(110, 45 + 8 * len(groups))) for _ in range(4)))
    axs = np.array(metric_axes, dtype=object)
    metrics=[('detected_protein_groups','Detected protein groups',False),('missing_pct','Missing proteins (%)',False),('median_observed_abundance','Median observed abundance (log10)',True),('total_observed_abundance','Total observed abundance (log10)',True)]
    for j,(ax,(metric,xlabel,log)) in enumerate(zip(axs.ravel(),metrics)):
        vals=[]
        for _,sub in groups:
            v=sub[metric].to_numpy(dtype=float)
            if log:
                assert (v>0).all();v=np.log10(v)
            vals.append(v)
        bp=ax.boxplot(vals,orientation='horizontal',patch_artist=True,widths=.55,medianprops={'color':'#16242E'},flierprops={'marker':'.','markersize':2})
        for k,box in enumerate(bp['boxes']):box.set_facecolor('#B0C7D6')
        # For small groups display all exact observations as well as degenerate boxes.
        for k,v in enumerate(vals):
            if len(v)<5:ax.scatter(v,np.repeat(k+1,len(v)),s=9,c='#233F56',zorder=4)
        ax.set_yticks(range(1,len(groups)+1),[f'{displays.get(str(g),str(g))} (n={len(sub)})' for g,sub in groups]);ax.invert_yaxis();ax.set_xlabel(xlabel)
        if j==0:ax.set_xlim(0,N*1.04)
        if j==1:ax.set_xlim(0,100)
        panel(ax,'abcd'[j],title)
    save_series(metric_figures, OUT, [f'Figure{fnum}_sample_depth_{field}',
        f'Figure{fnum}_missingness_{field}', f'Figure{fnum}_median_signal_{field}',
        f'Figure{fnum}_total_signal_{field}'])

landscape_figures, landscape_axes = zip(*(new_figure(183, 130) for _ in range(5)))
ax=landscape_axes[0]; order=np.argsort(-p.overall_detection_rate.to_numpy(),kind='stable')
rates=counts_by['group']/sizes_by['group'][:,None]
im=ax.imshow(rates[:,order]*100,aspect='auto',cmap='Blues',vmin=0,vmax=100,rasterized=True,interpolation='nearest')
ax.set_yticks(range(len(names_by['group'])),names_by['group']);ax.set_xlabel('All protein groups, ordered by global detection rate');ax.figure.colorbar(im,ax=ax,label='Detection (%)',shrink=.85,pad=.02)
panel(ax,'a','Detection landscape across regions')
ax=landscape_axes[1];xx=np.arange(len(breadth))
ax.bar(xx-.18,breadth.protein_groups_ge50pct,.36,color='#A8C1D1',label='Within-group ≥50%')
ax.bar(xx+.18,breadth.protein_groups_ge80pct,.36,color='#476E88',label='Within-group ≥80%')
ax.set_xticks(xx);ax.set_xlabel('Number of groups meeting threshold');ax.set_ylabel('Protein groups');ax.legend(frameon=False,fontsize=5.5)
panel(ax,'b','Cross-group detection breadth')
ax=landscape_axes[2];labs=['Global ≥80%','Global ≥90%','Every group ≥50%','Every group ≥80%','Both conditions ≥80%']
bars=ax.barh(range(5),core.protein_groups,color='#527D9E');ax.set_yticks(range(5),labs);ax.invert_yaxis();ax.bar_label(bars,padding=3,fontsize=6);ax.set_xlim(0,core.protein_groups.max()*1.22);ax.set_xlabel('Protein groups')
panel(ax,'c','Complementary core-coverage definitions')
ax=landscape_axes[3];assert (p.mean_observed_abundance>0).all()
ax.scatter(np.log10(p.mean_observed_abundance),p.missing_pct,s=3,c='#527D9E',alpha=.35,edgecolors='none',rasterized=True);ax.set_xlabel('Mean observed abundance (log10)');ax.set_ylabel('Missing samples (%)');panel(ax,'d','Observed abundance and missingness')
ax=landscape_axes[4];classorder=['Sparse (<50%)','Moderate (50–<80%)','High (80–<90%)','High (≥90%)'];sizes=p.coverage_class.value_counts().reindex(classorder)
bars=ax.barh(range(4),sizes,color=['#D5DEE4','#A8C1D1','#7596AD','#3D607B']);ax.set_yticks(range(4),classorder);ax.invert_yaxis();ax.bar_label(bars,padding=3,fontsize=6);ax.set_xlim(0,sizes.max()*1.22);ax.set_xlabel('Protein groups');panel(ax,'e','Global detection classes')
save_series(landscape_figures, OUT, ['Figure11_protein_detection_landscape', 'Figure11_detection_breadth',
    'Figure11_core_definitions', 'Figure11_abundance_missingness', 'Figure11_detection_classes'])

def md(frame):
    frame=frame.copy()
    for c in frame.select_dtypes('float'):frame[c]=frame[c].map(lambda v:f'{v:.2f}')
    return '| '+' | '.join(map(str,frame.columns))+' |\n| '+' | '.join(['---']*len(frame.columns))+' |\n'+'\n'.join('| '+' | '.join(map(str,r))+' |' for r in frame.itertuples(index=False,name=None))
selected=wide[wide.level.isin(['overall','condition','group'])][['level','category','samples']+focus]
summary=core.assign(说明=['全局检出率≥80%','全局检出率≥90%','每个地区均≥50%','每个地区均≥80%','两个环境均≥80%'])[['说明','protein_groups']]
treat_counts=s.TREAT1_clean.value_counts().reindex(['control','low','high','unknown','missing'],fill_value=0)
treat_description='、'.join(f'{label} {int(count)}' for label,count in treat_counts.items())
report=f'''# 正式QC前数据描述：四层完整报告

## 分析边界与数据口径
纳入519个矩阵样本列、3817个蛋白组。源文件SHA256与已核验版本相同，列头及各样本检出数再次核对。原始缺失率44.99%；无零值、负值或非数值；不删除、填补、归一化或校正数据。以下“蛋白”均按PG.ProteinGroups行计数。
定量矩阵来自此前processed工作簿；这里的“原始”指本轮未进一步变换的输入值，不声称是仪器原始信号或未经上游处理的数据。

## 第一层：样本构成
总体519例；high_temperature 280，high_stress 239；9个地区。TREAT1为{treat_description}。零样本类别在构成表中保留为0；覆盖率及箱线图仅对有样本的类别计算，不构造空组统计。
有8个进样日期，metadata没有独立MS_batch字段，因此全部按MS_batch_proxy命名。
已提供group×condition、group×TREAT1、日期×TREAT1、group×日期以及group×日期×TREAT1的计数表，并提供TREAT1行内比例。

关键结构：
- 地区嵌套于环境，不能独立估计地区与环境效应。
- XZ_YB：control 10、unknown 2，没有low/high；XZ_YA：control 2、low 19、high 1。地区内暴露构成不平衡。
- XZ_GG全部143例对应20260527；GZ_TH全部123例对应20260717，这两个地区与各自日期完全对应。
- 20251104仅2例，20251107仅1例，描述保留，但覆盖曲线高度离散，不能用来判断技术稳定性优劣。

![样本构成](Figure4_TREAT1_composition.png)
![地区与进样日期](Figure5_group_run_date.png)

## 第二层：蛋白覆盖度与检出率梯度
对overall、condition、group、TREAT1及日期均完成≥1%、≥10%、≥20%、≥30%、≥40%、≥50%、≥60%、≥70%、≥80%、≥90%、100%覆盖统计，另列“至少1例检出”。
**≥1%不等于至少1例**：总体519例中≥1%要求至少6例；每组用ceil(t×n/100)判定。整数比较避免浮点边界误差。
纵轴是“达到阈值的蛋白组数”；只是累计描述，无实际过滤。各阈值集合嵌套，不能相加。下表为正文重点50%–90%。

{md(selected)}

![地区覆盖梯度](Figure3_detection_gradient.png)
![总体、环境、暴露及日期覆盖梯度](Figure6_coverage_other_levels.png)

同一阈值下，小组n不同、暴露构成不同，曲线不能直接排名为生物学或技术质量高低。n=1时所有已检出蛋白在所有阈值均达标，平直曲线不是稳定性证据。

## 第三层：样本检测深度与原始信号
每个样本输出：detected proteins、missing proteins、missing %、观测正值中位数、观测正值总和、均值及Q1/Q3。
分别按condition、group、TREAT1、日期绘制检测数、缺失率、中位信号、总信号箱线图（Figure7–10）；信号仅在绘图时取log10。未把缺失填成0；观测总和仅加总有效值，不等同全蛋白组总量。
箱体Q1–Q3，线为中位数，须为1.5×IQR内最远值，离群观测保留。n<5额外显示每个样本。每个箱体单位为样本列，独立受试者身份尚未核实，不进行检验。
缺失蛋白数=3817−检出数，缺失率与检出数提供同一信息的不同尺度；不将其视为独立证据。

![按地区的样本深度与信号](Figure8_sample_depth_group.png)

## 第四层：蛋白检出一致性landscape
为每个蛋白提供全局、两个环境、9个地区、所有TREAT1标签及日期的检出率；输出在0–9个地区达标的分布和逐蛋白名单。
全局互斥分类采用<50%、50%–<80%、80%–<90%、≥90%；此外独立报告累计≥80%与≥90%“core”定义。core仅表示本队列中观测到的高检出覆盖，不等同普适的核心血浆蛋白组。

{md(summary)}

{md(breadth)}

![蛋白检出一致性](Figure11_protein_detection_landscape.png)

Figure11a展示全部蛋白在各地区的检出率（按全局检出率排序）；b展示每个蛋白在多少地区达到50%/80%；c是不同核心覆盖口径，集合可能重叠，不能相加；d为正值观测均值取log10与缺失率，不对缺失值补0；e为全局互斥覆盖分类。a/b/c/e为精确描述，无误差条或显著性检验。均值只由已检出值计算，缺失模式不能单独证明缺失机制。

## 文件与复现
- coverage_all_levels_long/wide.csv：五个层次完整梯度、实际需要检出的样本数（长表）、至少1例检出。
- sample_depth_and_signal.csv、sample_depth_signal_group_summaries.csv：样本明细和分层汇总。
- protein_detection_landscape.csv：完整蛋白检出率、分类与跨组广度。
- cross_group_detection_breadth.csv、core_coverage_counts.csv、proteins_*.csv：跨地区分布和各口径蛋白名单。
- Figure3–11均有PDF/SVG/PNG；原Figure1–2保留。样本结构详细交叉表见“QC前描述_样本构成与分析路线.md”。
- 运行顺序：describe_proteomics.py → detection_gradient.py → design_composition.py → complete_four_layers.py。

本轮不开展binary PCA、Jaccard聚类、异常样本剔除、插补或批次校正；样本检测相似性可以进入下一步正式QC。
'''
(OUT/'QC前数据描述_完整报告.md').write_text(report,encoding='utf-8')
print(summary.to_string(index=False),flush=True)
print(wide[wide.level=='overall'].to_string(index=False),flush=True)
print(breadth.to_string(index=False),flush=True)
print('PASS: all 519 samples and 3817 protein groups retained; counts and thresholds reconciled.',flush=True)
