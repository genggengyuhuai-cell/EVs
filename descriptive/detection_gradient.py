"""Descriptive detection thresholds; no filtering or imputation."""
from pathlib import Path
import hashlib
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
from nature_plotting import new_figure, save as save_nature

OUT = Path(__file__).resolve().parent
ROOT = OUT.parent
audit = json.loads((OUT/'audit.json').read_text(encoding='utf-8'))
for name in ['processed.xlsx','sample_mapping_FINAL.xlsx']:
    assert hashlib.sha256((ROOT/'rawdata'/name).read_bytes()).hexdigest() == audit[name+'_sha256'], 'Source changed: rerun describe_proteomics.py'
N = audit['protein_group_rows']
thresholds = np.arange(10,101,10)
records=[]; shared=[]; memberships={}
for field in ['group','condition']:
    rates=pd.read_csv(OUT/f'{field}_protein_detection_rate.csv')
    summary=pd.read_csv(OUT/f'{field}_summary.csv').set_index('category')
    assert len(rates)==N and rates.iloc[:,0].is_unique
    masks=[]
    for name in rates.columns[1:]:
        n=int(summary.loc[name,'samples'])
        r=rates[name].to_numpy()
        counts=np.rint(r*n).astype(int)
        assert np.allclose(r,counts/n,rtol=0,atol=1e-12)
        mask=np.array([counts*100 >= int(t)*n for t in thresholds])
        masks.append(mask)
        total=mask.sum(axis=1)
        assert (np.diff(total)<=0).all()
        assert int(total[4])==int(summary.loc[name,'detected_ge50pct'])
        assert int(total[7])==int(summary.loc[name,'detected_ge80pct'])
        assert int(total[9])==int(summary.loc[name,'detected_all'])
        for t,m,k in zip(thresholds,mask,total):
            required=(int(t)*n+99)//100
            records.append({'level':field,'category':name,'samples':n,'threshold_pct':int(t),'minimum_detected_samples':required,'effective_threshold_pct':required/n*100,'protein_groups':int(k),'pct_of_all_protein_groups':int(k)/N*100})
            if t in [50,60,70,80,90,100]:
                memberships[f'{name}_ge{t}pct']=m
    masks=np.array(masks)
    for i,t in enumerate(thresholds):
        shared.append({'level':field,'threshold_pct':int(t),'groups':len(masks),'all_groups_meet_threshold':int(masks[:,i,:].all(axis=0).sum()),'any_group_meets_threshold':int(masks[:,i,:].any(axis=0).sum())})

long=pd.DataFrame(records)
long.to_csv(OUT/'detection_gradient_long.csv',index=False,encoding='utf-8-sig')
common=pd.DataFrame(shared)
common.to_csv(OUT/'detection_gradient_shared.csv',index=False,encoding='utf-8-sig')
membership=pd.DataFrame({'PG.ProteinGroups':rates.iloc[:,0],**memberships})
membership.to_csv(OUT/'detection_gradient_membership.csv',index=False,encoding='utf-8-sig')
wide=long.pivot(index=['level','category','samples'],columns='threshold_pct',values='protein_groups').reset_index()
wide.to_csv(OUT/'detection_gradient_counts.csv',index=False,encoding='utf-8-sig')

sample=pd.read_csv(OUT/'sample_statistics.csv')
group_env=sample.groupby('group')['condition'].first().to_dict()
colors={'high_stress':'#527D9E','high_temperature':'#C48C59'}
names={'high_stress':'High stress','high_temperature':'High temperature'}
markers=['o','s','^','D','v']
styles=['-','--','-.',':','-']
for j,env in enumerate(['high_stress','high_temperature']):
    fig, ax = new_figure()
    subset=long[(long.level=='group') & long.category.map(group_env).eq(env)]
    for k,(name,df) in enumerate(subset.groupby('category')):
        ax.plot(df.threshold_pct,df.protein_groups,marker=markers[k],linestyle=styles[k],color=colors[env],markersize=3,linewidth=1,label=f'{name} (n={df.samples.iloc[0]})')
    ax.set_xticks([10,30,50,70,90,100]); ax.set_xlim(8,102); ax.set_ylim(0,3900)
    ax.set_xlabel('Minimum within-group detection (%)'); ax.set_ylabel('Protein groups meeting threshold')
    ax.set_title(f'Detection coverage gradient: {names[env]}',loc='left',pad=8)
    ax.legend(frameon=False,loc='lower left',ncol=2)
    save_nature(fig, OUT, f'Figure_03_detection_gradient_{env}', subset)
fig, ax = new_figure(183, 135)
main=wide[wide.level=='group'].set_index('category')
order=[g for env in ['high_stress','high_temperature'] for g in main.index if group_env[g]==env]
main=main.loc[order]; focus=[50,60,70,80,90,100]; arr=main[focus].to_numpy(dtype=int)
im=ax.imshow(arr,cmap='Blues',aspect='auto',vmin=0,vmax=3000)
ax.set_xticks(range(len(focus)),[f'≥{v}%' for v in focus])
ax.set_yticks(range(len(main)),[f'{g} (n={int(main.loc[g,"samples"])})' for g in main.index])
for i in range(len(main)):
    for j in range(len(focus)):
        ax.text(j,i,f'{arr[i,j]:,}',ha='center',va='center',fontsize=7,color='white' if arr[i,j]>1700 else '#172B3A')
ax.axhline(4.5,color='white',linewidth=2)
ax.set_title('Group-level protein coverage across detection thresholds',loc='left',pad=8)
ax.set_xlabel('Minimum within-group detection')
fig.colorbar(im,ax=ax,shrink=.8,pad=.02,label='Protein groups')
save_nature(fig, OUT, 'Figure_03_detection_gradient_group_threshold_counts', main.reset_index())
for level, sub in common.groupby('level'):
    fig, ax = new_figure()
    ax.plot(sub.threshold_pct, sub.all_groups_meet_threshold, 'o-', color='#3178A5', label='All groups')
    ax.plot(sub.threshold_pct, sub.any_group_meets_threshold, 's--', color='#C78132', label='Any group')
    display_level = {'group': 'groups', 'condition': 'environments'}[level]
    ax.set(xlabel='Detection threshold (%)', ylabel='Protein groups', title=f'Shared protein coverage across {display_level}')
    ax.legend()
    save_nature(fig, OUT, f'Figure_03_detection_gradient_shared_coverage_{level}', sub)

def table(df):
    return '| '+' | '.join(map(str,df.columns))+' |\n| '+' | '.join(['---']*len(df.columns))+' |\n'+'\n'.join('| '+' | '.join(map(str,r))+' |' for r in df.itertuples(index=False,name=None))
view=main.reset_index()[['category','samples']+focus].rename(columns={'category':'地区','samples':'样本数',**{t:f'≥{t}%' for t in focus}})
envview=wide[wide.level=='condition'][['category','samples']+focus].rename(columns={'category':'环境','samples':'样本数',**{t:f'≥{t}%' for t in focus}})
sharedview=common[(common.level=='group')&common.threshold_pct.isin(focus)]
report='''# QC前描述性分析补充：检出率梯度

## 口径与计算
沿用前次核验后的全部3817个蛋白组、519个样本，输入SHA256与前次一致。本分析不筛除样本或蛋白、不填补缺失。
在某组n个样本中，一个蛋白组有k个正且有限的定量值，组内检出率为k/n；阈值t%对应k×100≥t×n，即至少ceil(t×n/100)个样本检出。采用整数比较，避免浮点边界误差。
完整梯度10%–100%，步长10%；重点展示50%、60%、70%、80%、90%、100%。这些是嵌套的累计计数，不能相加。
分母始终是该组全部样本，蛋白百分比的分母为原始3817个蛋白组。样本数较小时实际阈值离散，例如XZ_YB有12例，≥80%需要10例（实际83.33%）。

## 各地区
'''+table(view)+'\n\n## 各环境\n'+table(envview)+'''\n
## 跨地区共同覆盖
下面为“每一个地区均达到阈值”的蛋白组交集，不等同于合并519个样本后的总体检出率达标。
'''+table(sharedview[['threshold_pct','all_groups_meet_threshold','any_group_meets_threshold']])+'''

## QC前还值得补充的描述层次

| 描述内容 | 回答的问题 | 建议展示 | 解释边界 |
| --- | --- | --- | --- |
| 地区×TREAT1×进样日期样本构成 | 哪些比较有样本、哪些组合为空、分组是否不平衡？ | 计数热图/堆叠条形图，保留unknown/missing | 进样日期可作运行分组，不自动等同已确认技术批次 |
| 跨组共同覆盖和交集 | 在相同检出率门槛下，各组覆盖的是不是同一批蛋白？ | 50%/80%集合交集、UpSet、Jaccard相似度 | 仅检出于某组不等同生物学特异性；本次已补充全地区交集梯度 |
| 等样本量的检出累积 | 各地区检出并集差异有多少受样本量影响？ | 稀释/累积曲线；共同样本量范围比较 | 重抽样是描述性标准化，不从原始分析中删样本；需展示重抽样波动 |
| 原始丰度与信号集中度 | 每个样本的信号范围和分布是否不同？ | 正值log分布、样本中位数/分位数、前10/20蛋白信号占比 | 先确认定量单位与既有处理；信号总和不等同总蛋白浓度 |
| 蛋白检出广度 | 普遍检出与稀疏检出蛋白各占多少？ | 每个蛋白达到50%/80%阈值的地区数分布及名单 | 地区计数不加权，和总体样本检出率不同 |
| metadata完整性和前处理分布 | 混匀、放置时间等信息是否完整，是否与地区/日期对应？ | 字段完整率、分类频数、数值分布和交叉表 | 先核实单位、编码与字段含义；不按未知编码推断影响 |

优先补充样本构成交叉表、跨组共同覆盖及等样本量累积曲线，再考虑丰度和前处理信息。这些用于了解数据与设计；本轮不选择过滤阈值、不执行归一化、插补、批次校正或差异分析。

## 图注与核验
Figure 03 为独立输出：高应激和高温环境内的地区检出率梯度、地区层面的重点阈值精确计数，以及按地区或环境汇总的共同覆盖曲线。线连接实测阈值计数，仅作视觉引导，不插值推断。n为矩阵样本列数；每点是固定数据的计数，无误差条或显著性检验。
每个组计数随阈值升高单调不增；50%、80%、100%结果与既有汇总逐项一致。完整长表包括实际所需样本数、实际离散阈值和蛋白比例；membership文件保留重点阈值下各蛋白组的布尔归属。
'''
(OUT/'QC前描述_检出率梯度.md').write_text(report,encoding='utf-8')
print(view.to_string(index=False))
print(envview.to_string(index=False))
print(sharedview.to_string(index=False))
