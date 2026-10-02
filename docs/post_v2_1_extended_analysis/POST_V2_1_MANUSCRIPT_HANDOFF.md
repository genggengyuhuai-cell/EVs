# Post-v2.1 Manuscript Handoff

For nature-statistics / manuscript writing.

## Headline protein-level result (Level 1)
- **85 proteins** BH-FDR<0.05 for High vs Low in the pooled Discovery cohort (n=386, 1,445 D01-eligible proteins, log2 abundance ~ 0 + dose + environment, eBayes trend=TRUE robust=TRUE).
- This is the primary endpoint. The contrast is **High vs Low** (two exposure groups), not exposed vs control.

## Pairwise vs Control (Level 2)
- Low vs Control: **0** BH-FDR<0.05 (114 raw P<0.05).
- High vs Control: **0** BH-FDR<0.05 (145 raw P<0.05).
- Exposure (Low+High) vs Control: **0** BH-FDR<0.05.
- Therefore the 85 are **not** exposed-vs-control DEPs. They represent High-vs-Low differences.

## Environment-stratified (Level 2, supplementary)
- Humid-heat (n=209): LVC=0, HVC=1, HvL=0, EC=0.
- High-altitude (n=177): LVC=0, HVC=75, HvL=0, EC=7.
- M10 Group × Environment interaction: 0/1,430 BH-FDR significant.
- Do not describe HA 75 / HA 7 as high-altitude-specific.

## Pathway (Level 1 for HvL; Level 3 for control-referenced)
- Frozen HvL cameraPR: 205 pooled BH-FDR<0.05 pathways (29 GO-BP + 176 Reactome).
- Exploratory LVC cameraPR: 258; HVC cameraPR: 38.
- These ranked pathway results use 1,406 mapped+estimable genes and moderated t ranking.
- Nominal-P ORA on 114/145 raw-P proteins: LVC=0, HVC=12 enriched (exploratory).

## Allowed prose (use verbatim or close)

> The primary protein-level distinction was between the Low and High exposure groups rather than between either exposure group and Controls. Although no individual Low-vs-Control or High-vs-Control proteins survived BH correction in the pooled Discovery analysis, ranked pathway analysis identified coordinated biological shifts relative to Controls. Low and High shared immune, complement, and acute-phase pathway activation, while selected proteostasis, cytoskeletal, redox, signaling, and extracellular-matrix programs differed in magnitude or direction across exposure states. These patterns are compatible with pathway-level remodeling across Low and High exposure states rather than a simple monotonic exposure response.

## Statistical reporting checklist

- n = 386 Discovery participants (Control 115, Low 139, High 132).
- Protein universe = 1,445 D01-eligible (group-specific ≥70% detection).
- Model: limma eBayes trend=TRUE robust=TRUE, ~0 + dose + environment.
- Contrasts: High vs Low (primary), Low vs Control, High vs Control, Exposure vs Control (secondary/supplementary).
- Multiplicity: BH per contrast family over estimable proteins.
- Pathway: cameraPR inter.gene.cor=0.01, set size 10–500, pooled BH across GO-BP + Reactome.
- Hold-out: reused within-cohort (n=129), not external validation.

## Do not write

- "Significant" without effect size and FDR.
- "High-altitude-specific" for HA hits.
- "Dose-response" or "monotonic" based on pairwise patterns.
- "Activation" of proteasome/cytoskeleton/redox for High when HVC is non-significant.
- "85 DEPs" without specifying High-vs-Low.

## Amendment paragraph (environment-stratified pathways)

"Environment-stratified ranked pathway analyses further indicated coordinated control-referenced remodeling despite sparse protein-level discoveries. For Low versus Control, no individual proteins survived BH correction in either environment, whereas 328 ranked pathways were significant in Humid-heat and 78 in High-altitude. Humid-heat High versus Control yielded 172 ranked pathways with one protein-level discovery, whereas High-altitude High versus Control yielded 11 ranked pathways alongside 75 protein-level discoveries. These findings indicate distinct patterns of distributed pathway-level and concentrated protein-level signal across strata; however, differences in pathway discovery counts were interpreted descriptively and not as evidence of formal environment-specific effects."
