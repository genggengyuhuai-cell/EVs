# FINAL REPRODUCIBILITY AUDIT（Phase 7 终态版）

> 日期：2026-10-01（Phase 7）。旧版备份：`.phase6.bak`（Phase 6 重建）、`.phase7.bak`（本次）。
> **全局：FREEZE_READINESS=BLOCKED · SUBMISSION_READINESS=BLOCKED · SAFE_TO_TAG=NO。**
> 分析侧 OPEN_ANALYSIS=0；剩余为 reporting / provenance / git。
> Ready_for_freeze=YES 仅当 Rerun_verified=YES 且 Reporting_frozen=YES 且 Provenance_complete=YES 且无未决重建。

## 逐模块表

| Module | Canonical_script | Canonical_input | Canonical_output | Rerun_verified | Reporting_frozen | Known_limitation | Provenance_complete | Ready_for_freeze |
|---|---|---|---|---|---|---|---|---|
| P1/P2/P3 upstream | code/P{1,2,3}.py | rawdata/processed.xlsx | rawdata/sample_mapping_FINAL.xlsx | N/A (deterministic) | N/A | no workbook identity binding (P1-7); manual ambiguous review | NO | NO |
| D01 eligibility | discovery_validation/D01_discovery_eligibility.py | raw 3817 | D01_discovery_eligibility/ (1445) | YES (frozen) | YES | depends on P1/P2/P3 provenance | NO | NO |
| D02 discovery | code/D02_discovery_primary.R | D01 | D02_discovery_primary/ | YES (frozen) | YES | M12 ranking source; depends upstream provenance | NO | NO |
| D03 lock | code/D03_candidate_lock.R | D02 | D03_candidate_lock/ (85) | YES (frozen) | YES | — | NO | NO |
| D04–D07,D09 | code/D0*.R | D03 | 各自目录 | YES (frozen) | YES | descriptive / reconciled | NO | NO |
| D08 hold-out | code/D08_validation.R | D03 + 129 | D08_validation/ (85/83/29/1) | YES (frozen) | YES | reused not external | NO | NO |
| D10 integrated | code/D10_integrated_biology.R | D05/D06/D07/D09 | D10_integrated_biology/ | NO | NO | P1-8 peptide propagation; rebuild pending | NO | NO |
| M05–M07,M10 | code/V2_M0[5-7,10]_*.R | Q515/1430 | 各 M0*_*/ | YES (frozen) | YES | M10 0/1430 null | NO | NO |
| M08 Firth | code/V2_M08_firth_detection.R | Q515 | M08_detection/Firth_primary/ | YES (frozen) | YES | supplementary | NO | NO |
| M09 KNN sensitivity | code/V2_M09_knn_sensitivity.R | Q515 + full515 + frozen M05 E | M09_missingness_sensitivity/KNN_sensitivity/ | YES (repaired) | YES | Fig3c rebuild pending (figure only) | NO | NO |
| M11 site LOO | code/V2_M11_site_robustness.R | Q515 | M11_site_robustness/ | YES (repaired) | YES | LOO sensitivity not replication; Fig4d rebuild pending | NO | NO |
| M12 pathway | M12_01→02→03 | D02 ranking + 85 fg + mapped | M12_pathway_v2.1/ | YES (repaired) | YES (fgsea dual frozen) | R03 universe switch deferred; Fig6b caption pending | NO | NO |
| M12B context | M12B_all.R | repaired M12 + 85 | M12B_biological_context_v2.1/ | YES (repaired) | YES | Spearman descriptive; secondary GO-MF/CC | NO | NO |
| M14 replication | code/V2_M13_M14_reconciliation.R | D08 + D03 | M14_frozen_replication/ | NO | NO | P1-6 hard-coded stale; rebuild from D08 | NO | NO |
| ML fixed-85 | ml_v2.1/run_v2_1_ml.R | 85 DEPs + Discovery | ml_v2.1/results/ | YES (repaired) | YES | conditional on frozen 85; Fig5 rebuild pending | NO | NO |
| ML strict nested | ml_v2.1/strict_nested_sensitivity.R | Discovery full | ml_v2.1/strict_nested/ | YES (repaired) | YES | 7/15 zero-feature; split generator provenance open | NO | NO |
| M17 figures | code/V2_M17_figures_v2.R | M05–M16 outputs | figures_final_v2/ | NO | NO | Fig3–6 rebuild required | NO | NO |
| KEGG | — | — | 0-row placeholder | N/A | N/A | NOT_RUN | N/A | N/A |

## 统计
- Rerun_verified=YES 的模块：D01/D02/D03/D04-D07/D09/D08（frozen）+ M05-M08/M10（frozen）+ M09/M11/M12/M12B（repaired）+ ML fixed-85/strict nested（repaired）。
- Reporting_frozen=YES：除 D10/M14/M17 外全部（fgsea dual 已冻结为 sensitivity-only）。
- Provenance_complete=YES：**0**（全部受 P1/P2/P3 workbook 身份绑定 + 环境锁定 + proteomics QC gap 影响）。
- **Ready_for_freeze=YES：0 个模块。**
  原因：分析侧已闭合，但全局 tag 被 OPEN_PROVENANCE（P1/P2/P3、环境锁定、QC gap）与 OPEN_REPORTING（Fig6/M14/D10 重建）阻断。

## 数值一致性（Phase 7 复核后）
- Cohort：519/515/153/186/176；Discovery 386 / hold-out 129。
- Discovery：1,445 eligible → 85 DEPs；replication 83/29/1。
- Interaction：0/1,430。
- Pathway（repaired）：cameraPR 205（29 BP+176 Reactome）/ ORA 23（3+20）/
  fgsea family 44（3/8/11/22）& pooled 41（6/7/10/18，DUAL sensitivity-only，REPORTING_FROZEN）/ KEGG NOT_RUN。
- Mapping：1434/1414/15/5；rankable N_ranked=1406。
- ML：fixed-85 mean outer AUROC LASSO 0.6651/EN 0.6687/XGB 0.6488；
  strict nested 7/15 zero-feature、8 evaluable、evaluable mean LASSO 0.5967/EN 0.5937。
- Universe distinction preserved：1445 inferential ≠ 1430 abundance Q515 ≠ 1434 pathway mapping ≠ 1414 mapped ≠ 1406 rankable。

## 结论
- 分析复现性：核心模块全部 Rerun_verified；**OPEN_ANALYSIS=0**。
- 不可 tag 的唯一原因已转移到 provenance + reporting + git，不再是分析缺陷。
- 首个 Ready_for_freeze=YES 的前置：P1/P2/P3 身份绑定 + 环境锁定 + Fig6/M14/D10 重建闭合。
