# Master project audit backlog

## Next phase: manual clean regeneration and validation

Status: **NOT YET STARTED**.

```text
01 → inspect
02 → inspect
03 → inspect
04 → inspect
05 → inspect
06 → inspect
07 → inspect
08a/b/c/d → inspect
09 → inspect
10a/b → inspect
11a/b → inspect
12 → inspect
run_all.py LAST
```

For actual dependency safety, Stage 09 must run before 08d because 08d consumes its
results; numbering does not imply adjacent dependencies. `descriptive/RUN_ORDER.md`
contains the exact manual sequence.

Final future item: **Clean end-to-end reproducibility test from rawdata using
`run_all.py`** — **NOT YET PERFORMED**. It may run only after all individual stages
have been manually executed and inspected.
