import csv, io
p = r"F:\env\manuscript_v2_1\audit\STATISTICAL_CLAIM_MAP.csv"
with open(p, encoding="utf-8-sig", newline="") as f:
    rows = list(csv.reader(f))
hdr = rows[0]
print("n_header_fields =", len(hdr))
for i, r in enumerate(rows[1:], start=2):
    if len(r) != len(hdr):
        print(f"ROW {i} (line {i}): fields={len(r)}  claim_id={r[0]!r}")
# Show C20 parsed fields aligned to header
for i, r in enumerate(rows[1:], start=2):
    if r and r[0] == "C20":
        print("--- C20 aligned ---")
        for h, v in zip(hdr, r):
            print(f"  {h}: {v[:120]}")
        if len(r) > len(hdr):
            print("  EXTRA FIELD:", r[len(hdr):])
