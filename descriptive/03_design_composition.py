"""Pre-QC descriptive composition; run dates are batch proxies only.
Quantitative grid: counts and row percentages expose cohort composition;
group-by-date matrix describes design overlap, without inferential tests.
183 mm, editable PDF/SVG, 600 dpi preview, all 519 columns retained.
"""
from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
from nature_plotting import new_figure, save as save_nature, EXPOSURE_LABELS, EXPOSURE_COLORS
OUT=Path(__file__).resolve().parent
if not (OUT/'sample_statistics.csv').is_file():
    raise FileNotFoundError(
        "Required Stage 01 output is missing: sample_statistics.csv. "
        "Run 01_describe_proteomics.py first."
    )
s=pd.read_csv(OUT/'sample_statistics.csv',keep_default_na=False)
assert len(s)==519 and s.UniqueSampleID.is_unique
s['MS_batch_proxy']=s['进样时间'].astype(str)
assert 'MS_batch' not in s.columns
treat=['control','low','high','unknown']
unexpected=set(s.TREAT1_clean)-set(treat)
if unexpected:
    raise ValueError(f'Unexpected TREAT1_clean labels: {sorted(unexpected)!r}; expected a subset of {treat!r}')
# A valid category may have zero samples; crosstab reindex below keeps its zero column.
tables={}
for field in ['group','MS_batch_proxy','condition']:
    counts=pd.crosstab(s[field],s.TREAT1_clean).reindex(columns=treat,fill_value=0)
    assert counts.to_numpy().sum()==len(s)
    pct=counts.div(counts.sum(axis=1),axis=0)*100
    counts.to_csv(OUT/f'{field}_by_TREAT1_counts.csv',encoding='utf-8-sig')
    pct.to_csv(OUT/f'{field}_by_TREAT1_row_pct.csv',encoding='utf-8-sig')
    tables[field]=(counts,pct)
cross=pd.crosstab(s['group'],s.MS_batch_proxy)
assert cross.to_numpy().sum()==519
cross.to_csv(OUT/'group_by_MS_batch_proxy_counts.csv',encoding='utf-8-sig')
triple=pd.crosstab([s['group'],s.MS_batch_proxy],s.TREAT1_clean).reindex(columns=treat,fill_value=0)
triple.to_csv(OUT/'group_by_MS_batch_proxy_by_TREAT1_counts.csv',encoding='utf-8-sig')
pal=[EXPOSURE_COLORS[key] for key in treat]
field_labels={'group':'Region','MS_batch_proxy':'Acquisition-date proxy','condition':'Environment'}
field_stems={'group':'region','MS_batch_proxy':'acquisition_date_proxy','condition':'environment'}
for i,field in enumerate(['group','MS_batch_proxy','condition']):
    counts,pct=tables[field]
    for j,frame in enumerate([counts,pct]):
        fig, ax = new_figure(183, max(100, 45 + 8 * len(frame)))
        left=np.zeros(len(frame))
        if j==0:
            arr=counts.to_numpy()
            ax.imshow(arr,cmap='Blues',vmin=0,vmax=max(1, arr.max()),aspect='auto')
            for row in range(len(counts)):
                for col in range(len(treat)):
                    ax.text(col,row,str(arr[row,col]),ha='center',va='center',fontsize=7,color='white' if arr[row,col]>arr.max() * 0.55 else '#18252C')
            ax.set_xticks(range(len(treat)),[EXPOSURE_LABELS[v] for v in treat])
            ax.set_yticks(range(len(counts)),[f'{v} (n={n})' for v,n in zip(counts.index,counts.sum(axis=1))])
            ax.set_xlabel('Exposure group (cells show sample counts)')
            ax.set_title(f'{field_labels[field]} by exposure group',loc='left',pad=8)
            name = f'Figure_04_design_composition_{field_stems[field]}_exposure_counts'
            save_nature(fig, OUT, name, counts.reset_index())
            continue
        for k,c in enumerate(treat):
            vals=frame[c].to_numpy()
            ax.barh(np.arange(len(frame)),vals,left=left,color=pal[k],label=EXPOSURE_LABELS[c],height=.72)
            for row,v in enumerate(vals):
                if v and (j==0 or v>=7):
                    ax.text(left[row]+v/2,row,str(int(v)) if j==0 else f'{v:.0f}',ha='center',va='center',fontsize=6,color='white' if c=='high' else '#18252C')
            left+=vals
        ax.set_yticks(np.arange(len(frame)),[f'{v} (n={n})' for v,n in zip(frame.index,counts.sum(axis=1))]); ax.invert_yaxis()
        ax.set_xlabel('Samples (n)' if j==0 else 'Within-row composition (%)')
        if j: ax.set_xlim(0,100)
        ax.set_title(f'{field_labels[field]} by exposure group',loc='left',pad=8)
        ax.legend()
        save_nature(fig, OUT, f'Figure_04_design_composition_{field_stems[field]}_exposure_proportions', frame.reset_index())
fig,ax=new_figure(183, 130)
a=cross.to_numpy(); im=ax.imshow(a,cmap='Blues',vmin=0,vmax=a.max(),aspect='auto')
ax.set_xticks(range(len(cross.columns)),cross.columns,rotation=45,ha='right',rotation_mode='anchor')
ax.set_yticks(range(len(cross)),cross.index)
for i in range(a.shape[0]):
    for j in range(a.shape[1]):
        ax.text(j,i,str(a[i,j]),ha='center',va='center',fontsize=7,color='white' if a[i,j]>a.max()*.55 else '#233746')
ax.set_xlabel('Acquisition date (proxy; not a confirmed batch ID)'); ax.set_ylabel('Region'); ax.set_title('Region by acquisition-date proxy: sample allocation',loc='left')
fig.colorbar(im,ax=ax,label='Samples (n)',shrink=.8)
save_nature(fig, OUT, 'Figure_04_design_composition_region_by_acquisition_date_proxy', cross.reset_index())
def md(df):
    d=df.reset_index()
    return '| '+' | '.join(map(str,d.columns))+' |\n| '+' | '.join(['---']*len(d.columns))+' |\n'+'\n'.join('| '+' | '.join(map(str,row))+' |' for row in d.itertuples(index=False,name=None))
report='''# QC前样本构成与后续描述路线

## 定义
基于已核验的519个样本列，TREAT1使用标准化标签。control/low/high/unknown全部保留，。样本列数不等同已确认独立受试者数。
metadata没有独立MS_batch字段，本轮使用进样时间的8个日期作为MS_batch_proxy。日期不等同已确认技术批次，不能排除同日多批次或跨日同批次，最终应结合上机记录确认。

## group × TREAT1：样本数
'''+md(tables['group'][0])+'''\n
## MS运行日期 × TREAT1：样本数
'''+md(tables['MS_batch_proxy'][0])+'''\n
## group × MS运行日期：样本数
'''+md(cross)+'''

## QC前还能分析什么

1. **设计结构**：上述两张交叉表配套行内比例，再看group×MS_batch和group×MS_batch×TREAT1。识别空组合、小样本组合、地区与日期对应关系。本轮已输出三维明细；未进行检验或剔除。
2. **检出覆盖梯度**：每个group的50/60/70/80/90/100%覆盖已完成，完整曲线10%起。还可按group×TREAT1计算，但必须标明各小组n；特别小的组不适合直接比较阈值曲线。
3. **共同覆盖与组间交集**：分别在50%和80%门槛下展示UpSet或Jaccard矩阵，区分“总体达标”和“每个地区均达标”；已有全地区共同覆盖梯度和蛋白名单。
4. **等样本量检出累积**：用共同样本量范围的稀释曲线比较覆盖深度，解释为什么某些样本多的组并集更大。保留全部原始数据，重抽样只用于标准化展示，并给出波动区间。
5. **样本层面信号分布**：原始正值的log强度分布、每个样本中位数/IQR及高丰度蛋白信号占比；按地区、日期和TREAT1展示。在确认定量单位和原有处理前不解释为血浆总蛋白浓度。
6. **蛋白检出广度**：一个蛋白在多少地区达到50%/80%，可形成“广泛覆盖/局部覆盖/稀疏检出”的描述。命名仅指观测覆盖，不等同环境特异或候选biomarker。
7. **前处理信息完整性**：Tube_Mixing、WoleBlood_oldTime、Plasma_HoldTime_h、TREAT2的完整率和取值分布，再交叉地区/日期。先确认数值单位、Unknown与0的含义；不能把Unknown当成0。
8. **注释层面**：蛋白组对应的accession数量、基因注释完整率、单蛋白组/多蛋白组比例；PG.Qvalue与PG.CV可先描述，但必须核实生成软件的字段定义，再讨论过滤用途。

建议顺序：样本构成与日期对应 → 检出率梯度 → 共同覆盖/等样本量累积 → 原始信号和前处理描述。PCA、异常样本剔除、插补和批次校正留到后续QC与分析方案阶段。

## 图注与复核
Figure 04 为独立的地区、acquisition-date proxy 和环境构成图，分别展示精确样本数与行内比例；少于7%的比例不标数字以避免拥挤，完整数值见CSV。另一个独立输出展示所有地区×acquisition-date proxy 的精确计数，包括零格。所有计数总和均核对为519，比例分母为各行样本数。没有误差条或统计检验。
'''
(OUT/'QC前描述_样本构成与分析路线.md').write_text(report,encoding='utf-8')
print(tables['group'][0].to_string());print(tables['MS_batch_proxy'][0].to_string());print(cross.to_string())
