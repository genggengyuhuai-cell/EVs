import csv
p = r"F:\env\manuscript_v2_1\audit\STATISTICAL_CLAIM_MAP.csv"
with open(p, encoding="utf-8-sig", newline="") as f:
    rows = list(csv.reader(f))
hdr = rows[0]
bad = [(i+2, len(r)) for i, r in enumerate(rows[1:]) if len(r) != len(hdr)]
print("header_fields =", len(hdr), "data_rows =", len(rows)-1, "misaligned =", bad if bad else "NONE")
for i, r in enumerate(rows[1:], start=2):
    if r and r[0] in ("C20","C28","C29"):
        d = dict(zip(hdr, r))
        print(f"{d['Claim_ID']}: Status={d['Status']} | Blocking={d['Blocking_module']} | Reason={d['Reason_20261001'][:70]}")
