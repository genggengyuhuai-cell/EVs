from pathlib import Path
import hashlib  # [Phase7 FIX]

import pandas as pd


# ============================================================
# Paths
# ============================================================

AUDIT_FILE = Path("../rawdata/sample_mapping_audit.xlsx")
OUTPUT_FILE = Path("../rawdata/sample_mapping_ambiguous_context.xlsx")
PROVENANCE_FILE = Path('../rawdata/sample_mapping_provenance.txt')  # [Phase7 FIX]




# ============================================================
# [Phase7 FIX] Source identity / provenance (SHA256) contract
# ============================================================
# P2 reads sample_mapping_audit.xlsx (produced by P1)
# Verifies audit file hash matches the value recorded by P1/P3

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def check_provenance_p2():
    h_audit = sha256_file(AUDIT_FILE)
    if PROVENANCE_FILE.exists():
        recorded = {}
        with open(PROVENANCE_FILE, "r") as f:
            for line in f:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    k, v = line.split("=", 1)
                    recorded[k] = v
        expected = recorded.get("sample_mapping_audit_xlsx_sha256")
        if expected and expected.lower() != h_audit.lower():
            raise RuntimeError(
                f"[Phase7 PROVENANCE MISMATCH] sample_mapping_audit.xlsx hash changed!\n"
                f"  Recorded: {expected}\n  Current:  {h_audit}\n"
                f"  Refusing to write {OUTPUT_FILE.name}."
            )
        print(f"  [Phase7] Provenance OK: audit.xlsx SHA256 matches.")
    else:
        print(f"  [Phase7] WARNING: No provenance file found. Run P1 first to record hashes.")


check_provenance_p2()


# ============================================================
# Read audit results
# ============================================================

mapping = pd.read_excel(
    AUDIT_FILE,
    sheet_name="01_All_Mapping"
)

review = mapping.loc[
    mapping["Final_status"] == "AMBIGUOUS"
].copy()


# ============================================================
# Print summary
# ============================================================

print(
    "============================================================"
)
print(
    "AMBIGUOUS SAMPLE CONTEXT CHECK"
)
print(
    "============================================================"
)

print(
    "Ambiguous columns:",
    len(review)
)


# ============================================================
# Add neighboring Sheet1 columns
# ============================================================

all_headers = mapping[
    [
        "Sheet1_position",
        "Sheet1_raw_header",
        "Final_status",
        "UniqueSampleID",
        "group"
    ]
].copy()

pos_to_row = {
    int(row["Sheet1_position"]): row
    for _, row in all_headers.iterrows()
}


records = []

for _, row in review.iterrows():

    pos = int(
        row["Sheet1_position"]
    )

    rec = {
        "Sheet1_position":
            pos,

        "Sheet1_raw_header":
            row["Sheet1_raw_header"],

        "Sheet1_normalized":
            row["Sheet1_normalized"],

        "candidate_count":
            row["candidate_count"],

        "Candidate_details":
            row.get(
                "Candidate_details",
                ""
            )
    }

    # --------------------------------------------------------
    # Add 3 previous + 3 following Sheet1 columns
    # --------------------------------------------------------

    for offset in [
        -3,
        -2,
        -1,
        1,
        2,
        3
    ]:

        neighbor_pos = (
            pos +
            offset
        )

        label = (
            f"neighbor_{offset:+d}"
        )

        if neighbor_pos in pos_to_row:

            nrow = pos_to_row[
                neighbor_pos
            ]

            rec[
                f"{label}_header"
            ] = nrow[
                "Sheet1_raw_header"
            ]

            rec[
                f"{label}_status"
            ] = nrow[
                "Final_status"
            ]

            rec[
                f"{label}_group"
            ] = nrow[
                "group"
            ]

            rec[
                f"{label}_UniqueSampleID"
            ] = nrow[
                "UniqueSampleID"
            ]

        else:

            rec[
                f"{label}_header"
            ] = None

            rec[
                f"{label}_status"
            ] = None

            rec[
                f"{label}_group"
            ] = None

            rec[
                f"{label}_UniqueSampleID"
            ] = None

    records.append(
        rec
    )


context = pd.DataFrame(
    records
)


# ============================================================
# Save
# ============================================================

with pd.ExcelWriter(
    OUTPUT_FILE,
    engine="openpyxl"
) as writer:

    context.to_excel(
        writer,
        sheet_name="Ambiguous_Context",
        index=False
    )

    review.to_excel(
        writer,
        sheet_name="Original_Ambiguous",
        index=False
    )


# ============================================================
# Console preview
# ============================================================

cols_to_print = [
    "Sheet1_position",
    "Sheet1_raw_header",
    "neighbor_-1_header",
    "neighbor_-1_group",
    "neighbor_+1_header",
    "neighbor_+1_group",
    "candidate_count",
    "Candidate_details"
]

print()

print(
    context[
        cols_to_print
    ]
    .head(
        80
    )
    .to_string(
        index=False
    )
)

print(
    "\n============================================================"
)

print(
    "Output:"
)

print(
    OUTPUT_FILE
)

print(
    "============================================================"
)