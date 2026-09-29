# Experimental Design Review — v2.1

## 2.1 Cohort structure

| Quantity | Value | Comment |
|---|---|---|
| Initial | 519 | Screened |
| Analytical | 515 | 4 excluded after QC |
| Control / Low / High | 153 / 186 / 176 | Reasonably balanced; High slightly larger than Control. |
| Discovery | 386 | Pre-specified split |
| Reused hold-out | 129 | Same cohort, later-defined |

**What this design supports:**
- A within-cohort discovery of proteins associated with the High-vs-Low contrast.
- A within-cohort check of direction and nominal significance in a held-out subset.
- Multi-site descriptive robustness.

**What this design does not support:**
- Independent / external / prospective validation.
- A dose-response claim (only three exposure categories, not a continuous gradient).
- Population-level generalizability.

**Reused hold-out consequences:**
- The 129 subjects come from the same enrollment, same sites, same platform, same processing batches as the 386.
- Direction concordance (83/85) is therefore **inflated relative to true external replication** — subjects share preanalytical and environmental context.
- The 29 nominal / 1 FDR-supported numbers must be read as within-cohort stability, not validation.
- Group balance and site distribution across Discovery vs hold-out should be reported (not assumed balanced).

**Data reuse:** yes — the 129 are reused from the same enrolled cohort. This must be stated explicitly.

## 2.2 Exposure definition

- "Control / Low / High" are exposure-category labels, not measured continuous doses.
- The overall-exposure family is **null (0/1,430 at BH-FDR<0.05)**, which undercuts a monotone dose story.
- The discovery contrast is High-vs-Low (not High-vs-Control, not a trend). This means the 85 DEPs are a **High-vs-Low contrast result**, not a dose-response result.
- **"Dose" terminology should be avoided.** Use "exposure category" / "High vs Low exposure contrast".
- High land vs Hot-humid is **environment**, not exposure; it is partially confounded with site and potentially with exposure category. The manuscript must not treat environment as an independent dose axis.

## 2.3 Site structure

- Sites are **not independent replication arms**. They are likely coupled to environment (High land sites vs Hot-humid sites) and possibly to processing batches.
- Leave-one-site-out (LOO) can show: direction stability of a protein-level estimate when one site is omitted.
- LOO cannot show: replication, generalizability, or absence of site confounding.
- Preanalytical / batch / site-processing effects are possible but not formally modeled; site is a robustness dimension, not a controlled confounder.

## 2.4 Environment structure

- Environment-stratified estimates (High land vs Hot-humid) are **descriptive concordance**, not effect modification.
- Formal interaction test (M10) is **null (0/1,430 at BH-FDR<0.05)** and underpowered.
- Stratified concordance is weak evidence for "environment-consistent signal"; it is more honestly a descriptive sensitivity.
- Recommendation: environment/stratification belongs in **robustness / sensitivity**, not as a primary result.

## 3.1 Study material — safest definition

The measured material is **EV-enriched plasma proteome** — a magnetic-bead (Mag-Net) enriched fraction from plasma. It is **not** demonstrably a pure EV proteome. The safest manuscript wording is:

> "EV-enriched plasma proteomic profiling of plasma, obtained by magnetic-bead enrichment."

Do **not** claim:
- pure EV proteome
- endosomal / EV cargo
- EV-specific biology
- release from specific cell types

without additional validation.

## 3.2 Biological interpretation boundary

| Claim | Status |
|---|---|
| "Plasma proteins differ between exposure categories" | Supported |
| "The enriched fraction is EV-associated" | Partially supported (enrichment method, no purity control) |
| "These are EV proteins" | Not supported (co-isolation of abundant plasma / platelet / RBC / coagulation proteins is expected) |
| "EV biology explains the signal" | Not supported |

Required disclaimers: abundant plasma-protein contamination, platelet/RBC/coagulation contributions, and lack of EV-marker / proteolipid / NTA / cryoEM controls must be acknowledged.

## 3.3 Preanalytical variables

| Variable | Status in current design |
|---|---|
| Collection site | Measured; coupled to environment |
| Processing batch | Not explicitly modeled |
| Freeze-thaw | Not reported as controlled |
| Storage time / temperature | Not reported |
| Processing time | Not reported |
| Centrifugation / pre-clear | Not reported |
| MS run order | Not reported as randomized |
| Sample handling | Not reported |

These are **limitations**, not blockers, but they must be stated. No new preanalytical experiment is required for submission if the word "EV-enriched" is kept and contamination is acknowledged.

## 4. Module-by-module design verdict

- **Discovery (High vs Low, 85 DEPs)**: central empirical result; keep as main.
- **Overall exposure (0/1430)**: important null context; keep as main (it sets up why High-vs-Low is the contrast).
- **Pairwise contrasts (13/0/257)**: main as secondary table.
- **Detection (Firth, 2/3054)**: Supplement / robustness.
- **Missingness (KNN on 85)**: Supplement.
- **Interaction (0/1430)**: main as a stated null; do not bury.
- **Site LOO**: Supplement / robustness.
- **Environment stratified**: Supplement / descriptive.
- **Replication hierarchy (85/83/29/1)**: main.
- **Fixed-85 ML**: main as sensitivity / prioritization, not performance claim.
- **Strict nested ML**: Supplement.
- **Boruta-style / XGBoost importance**: Supplement.
- **Pathway cameraPR 195**: main as representative themes (top GO BP + core Reactome clusters), not all 195.
- **ORA 23 / fgsea 39**: Supplement / concordance.
- **M12B annotation / network / correlation**: Supplement / interpretation.

## 5. What the design supports and does not support

**Supports:**
- A pre-specified, FDR-controlled Discovery of 85 High-vs-Low exposure-associated plasma proteins.
- Within-cohort direction concordance in a reused hold-out.
- Multi-method robustness (detection, missingness, site LOO, environment-stratified).
- A descriptive pathway/context layer.

**Does not support:**
- Independent/external validation.
- Dose-response.
- EV-pure biology.
- Mechanistic / causal claims.
- Generalization to new populations.
- Predictive performance as a clinical tool.
