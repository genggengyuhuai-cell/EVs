# Project Documentation Index

> ## 🚧 项目总状态（2026-10-01）：BLOCKED，禁止打 tag
>
> **FREEZE_READINESS=BLOCKED · SUBMISSION_READINESS=BLOCKED · ANALYSIS_REOPEN_REQUIRED=YES · SAFE_TO_TAG_ANALYSIS_V2_1=NO**
>
> **分析侧已修复闭合，全局仍 BLOCKED 的原因为 reporting/provenance/git：**
> fixed-85 ML=REPAIRED_AND_VERIFIED；strict nested=REPAIRED_AND_VERIFIED；M09=REPAIRED_AND_VERIFIED；
> M11=REPAIRED_AND_VERIFIED；M12=REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD；M12B=REPAIRED_RERUN_COMPLETE；
> Fig6=NOT_FINAL（待重建）；fgsea canonical FDR=UNRESOLVED（HOLD）；KEGG=NOT_RUN。
> 历史通路 195/23/39=PRE_REPAIR_EXISTING_OUTPUT（仅存于 pre_repair_snapshot，非 FINAL_FROZEN）；
> current 通路数：cameraPR 205（29+176）、ORA 23（3+20）、fgsea family 44 / pooled 41。
>
> 本目录下 `FINAL_REPRODUCIBILITY_AUDIT.md`（2026-09-29 "PASS / READY_TO_TAG" 原版已 SUPERSEDED；
> Phase 6 重建版同文件顶部）；以根目录 `PROJECT_CONTEXT.md` 顶部权威总状态、
> `docs/FINAL_BLOCKER_STATUS.md` 与 `docs/PHASE6_STATUS_BASELINE.md` 为准。

## 权威层级（谁说了算）

当文档之间出现差异时，按以下优先级从高到低裁决：

```
1. PROJECT_CONTEXT.md                        ← 项目总纲，最高权威
       ↓
2. docs/protocol/ANALYSIS_PLAN_v2.0.md       ← v2 总分析协议（当前有效）
       ↓
3. docs/protocol/STUDY_DESIGN_AUDIT.md       ← v2 设计审计与证据锚点
       ↓
4. docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md
   + DISCOVERY_VALIDATION_SPLIT_SPEC.md      ← 历史 prospective 协议
       ↓
5. docs/workflow/                            ← 工作流、文件状态、审计清单
       ↓
6. 模块级 README / RUN_ORDER / README_METHODS ← 代码与结果旁边的说明
       ↓
7. docs/archive/                             ← 历史归档，仅供追溯
```

> **关键原则**：Historical frozen protocols remain authoritative for reproducing their
> historical analyses; **Analysis Plan v2.0 is authoritative for all new v2 analyses.**
>
> 归档中的 `legacy_framework_v2.0/` 是历史全队列框架，不是当前有效协议。
> 看到 `docs/protocol/ANALYSIS_PLAN_v2.0.md` 就是当前执行依据；
> 看到 `docs/archive/legacy_framework_v2.0/` 就是历史材料。

## 目录结构

```
docs/
├── README.md                    ← 本文件
├── workflow/                    ← 做到哪了
│   ├── CODEX_WORKFLOW.md
│   ├── FILE_STATUS.md
│   └── MASTER_PROJECT_AUDIT_BACKLOG.md
├── protocol/                    ← 做什么和怎么做
│   ├── ANALYSIS_PLAN_v2.0.md              ← v2 总分析协议（最高级）
│   ├── STUDY_DESIGN_AUDIT.md              ← v2 设计审计
│   ├── DISCOVERY_VALIDATION_PROTOCOL.md   ← 历史 prospective 协议
│   └── DISCOVERY_VALIDATION_SPLIT_SPEC.md
├── task/                        ← 现在做什么
│   └── TASK_CURRENT.md
└── archive/                     ← 历史材料，永不作为当前执行依据
    ├── legacy_framework_v2.0/   ← 历史全队列 v2.0 框架文档
    ├── maintenance_logs/         ← 代码维护迭代记录 v2.0~v2.4
    └── early_plans/             ← 早期 QC 与 limma 分析计划
```

## 一句话规则

> **根目录只有入口；`docs/protocol` 决定"做什么和怎么做"；`docs/workflow` 记录"做到哪"；`docs/task` 规定"现在做什么"；模块 README 解释"这段代码怎么工作"；`archive` 永远不能作为当前执行依据。**
