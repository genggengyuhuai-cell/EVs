options(stringsAsFactors = FALSE)

input_file <- "F:/env/descriptive/dose_defined_metadata.csv"
output_dir <- "F:/env/descriptive/discovery_validation_split"
assignment_file <- file.path(output_dir, "discovery_validation_assignment.csv")
assertion_file <- file.path(output_dir, "split_integrity_assertions.csv")
manifest_file <- file.path(output_dir, "split_manifest.txt")
protocol_version <- "DiscoveryValidationProtocol_v1.0"
frozen_seed <- 20260925L
pre_randomization_only <- "--pre-randomization-only" %in% commandArgs(trailingOnly = TRUE)

if (file.exists(assignment_file) || file.exists(manifest_file)) {
    stop("Existing assignment or manifest detected; refusing to execute.")
}

metadata <- read.csv(
    input_file,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    encoding = "UTF-8"
)

required_columns <- c("UniqueSampleID", "condition", "TREAT1_clean", "group")
if (!all(required_columns %in% names(metadata))) {
    stop("Canonical input lacks one or more required columns.")
}

strata <- data.frame(
    Environment_key = c("HumidHot", "HumidHot", "HumidHot", "HighPressure", "HighPressure", "HighPressure"),
    TREAT1_clean = c("control", "low", "high", "control", "low", "high"),
    Internal_stratum = c(
        "HumidHot_Control",
        "HumidHot_Short",
        "HumidHot_Long",
        "HighPressure_Control",
        "HighPressure_Short",
        "HighPressure_Long"
    ),
    Stratum = c(
        "Humid-hot / Control",
        "Humid-hot / Short",
        "Humid-hot / Long",
        "High-pressure/high-altitude / Control",
        "High-pressure/high-altitude / Short",
        "High-pressure/high-altitude / Long"
    ),
    Total = c(95L, 83L, 101L, 58L, 103L, 75L),
    Discovery = c(71L, 62L, 76L, 44L, 77L, 56L),
    Validation = c(24L, 21L, 25L, 14L, 26L, 19L),
    stringsAsFactors = FALSE
)

missing_value <- function(x) is.na(x) | trimws(x) == ""
utf8_hex <- function(x) {
    vapply(x, function(value) {
        if (is.na(value)) return(NA_character_)
        paste(sprintf("%02x", as.integer(charToRaw(value))), collapse = "")
    }, character(1))
}

group_environment <- c(
    FJ_FQ = "HumidHot",
    FJ_PT = "HumidHot",
    FJ_QZ = "HumidHot",
    GZ_TH = "HumidHot",
    XZ_GG = "HighPressure",
    XZ_YA = "HighPressure",
    XZ_YB = "HighPressure",
    XZ_YC = "HighPressure",
    XZ_YD = "HighPressure"
)
environment_condition_hex <- c(
    HumidHot = "e6b9bfe783ad",
    HighPressure = "e9ab98e6b5b7e68b94"
)
dose_key <- c(control = "Control", low = "Short", high = "Long")

metadata$Environment_key <- unname(group_environment[metadata$group])
metadata$Condition_utf8_hex <- utf8_hex(metadata$condition)
metadata$Internal_stratum <- paste(
    metadata$Environment_key,
    unname(dose_key[metadata$TREAT1_clean]),
    sep = "_"
)
mapping_key <- strata$Internal_stratum
row_key <- metadata$Internal_stratum
mapping_index <- match(row_key, mapping_key)
metadata$Stratum <- strata$Stratum[mapping_index]

input_counts <- table(factor(metadata$Stratum, levels = strata$Stratum))
condition_consistent <- (
    !is.na(metadata$Environment_key) &
    !is.na(metadata$Condition_utf8_hex) &
    metadata$Condition_utf8_hex == unname(environment_condition_hex[metadata$Environment_key])
)
pre_results <- c(
    nrow(metadata) == 515L,
    length(unique(metadata$UniqueSampleID)) == 515L,
    sum(missing_value(metadata$UniqueSampleID)) == 0L,
    sum(missing_value(metadata$condition)) == 0L,
    sum(missing_value(metadata$TREAT1_clean)) == 0L,
    all(condition_consistent),
    all(metadata$TREAT1_clean %in% c("control", "low", "high")),
    all(!is.na(mapping_index)) && length(mapping_index) == nrow(metadata),
    identical(as.integer(input_counts), strata$Total)
)
names(pre_results) <- sprintf("A%02d", 1:9)

if (any(!pre_results)) {
    stop(paste("Pre-randomization assertions failed:", paste(names(pre_results)[!pre_results], collapse = ", ")))
}

if (pre_randomization_only) {
    cat("PRE_RANDOMIZATION_DRY_RUN=PASS\n")
    cat("RNGKIND_CALLS=0\n")
    cat("SET_SEED_CALLS=0\n")
    cat("SAMPLE_CALLS=0\n")
    cat("ASSERTIONS=A01-A09 PASS\n")
    cat("ROWS=", nrow(metadata), "\n", sep = "")
    cat("UNIQUE_PARTICIPANTS=", length(unique(metadata$UniqueSampleID)), "\n", sep = "")
    cat("CONDITION_UTF8_HEX=", paste(unique(metadata$Condition_utf8_hex), collapse = "|"), "\n", sep = "")
    cat("ASCII_STRATUM_COUNTS\n")
    print(table(factor(metadata$Internal_stratum, levels = strata$Internal_stratum)))
    quit(save = "no", status = 0L, runLast = FALSE)
}

if (any(!grepl("^[\\x20-\\x7E]+$", metadata$UniqueSampleID, perl = TRUE))) {
    stop("UniqueSampleID contains non-ASCII characters; frozen ordering contract cannot be applied.")
}

ordered_ids <- lapply(seq_len(nrow(strata)), function(i) {
    ids <- metadata$UniqueSampleID[metadata$Internal_stratum == strata$Internal_stratum[i]]
    sort(ids, method = "radix")
})

RNGkind(
    kind = "Mersenne-Twister",
    normal.kind = "Inversion",
    sample.kind = "Rejection"
)
set.seed(20260925)

permuted_ids <- vector("list", nrow(strata))
for (i in seq_len(nrow(strata))) {
    x <- ordered_ids[[i]]
    permuted_ids[[i]] <- sample(x, size = length(x), replace = FALSE)
}

split_lookup <- setNames(rep(NA_character_, nrow(metadata)), metadata$UniqueSampleID)
for (i in seq_len(nrow(strata))) {
    perm <- permuted_ids[[i]]
    n_validation <- strata$Validation[i]
    split_lookup[perm[seq_len(n_validation)]] <- "Validation"
    split_lookup[perm[-seq_len(n_validation)]] <- "Discovery"
}

assignment <- metadata[, c("UniqueSampleID", "condition", "TREAT1_clean", "group", "Stratum")]
assignment$Split <- unname(split_lookup[assignment$UniqueSampleID])
assignment$Seed <- frozen_seed
assignment$Protocol_version <- protocol_version
assignment$Stratum_order <- match(assignment$Stratum, strata$Stratum)
assignment <- assignment[order(assignment$Stratum_order, assignment$UniqueSampleID, method = "radix"), ]
assignment$Stratum_order <- NULL
rownames(assignment) <- NULL

split_counts <- table(
    factor(assignment$Stratum, levels = strata$Stratum),
    factor(assignment$Split, levels = c("Discovery", "Validation"))
)
metadata_match <- match(assignment$UniqueSampleID, metadata$UniqueSampleID)
metadata_agreement <- all(
    assignment$condition == metadata$condition[metadata_match] &
    assignment$TREAT1_clean == metadata$TREAT1_clean[metadata_match] &
    assignment$group == metadata$group[metadata_match]
)

post_results <- c(
    nrow(assignment) == 515L,
    length(unique(assignment$UniqueSampleID)) == 515L,
    sum(assignment$Split == "Discovery") == 386L,
    sum(assignment$Split == "Validation") == 129L,
    identical(as.integer(split_counts[1, ]), c(71L, 24L)),
    identical(as.integer(split_counts[2, ]), c(62L, 21L)),
    identical(as.integer(split_counts[3, ]), c(76L, 25L)),
    identical(as.integer(split_counts[4, ]), c(44L, 14L)),
    identical(as.integer(split_counts[5, ]), c(77L, 26L)),
    identical(as.integer(split_counts[6, ]), c(56L, 19L)),
    sum(missing_value(assignment$Split)) == 0L,
    all(assignment$Split %in% c("Discovery", "Validation")),
    setequal(metadata$UniqueSampleID, assignment$UniqueSampleID) && all(table(assignment$UniqueSampleID) == 1L),
    all(assignment$UniqueSampleID %in% metadata$UniqueSampleID),
    all(assignment$Seed == frozen_seed),
    all(assignment$Protocol_version == protocol_version),
    metadata_agreement
)
names(post_results) <- sprintf("A%02d", 10:26)
all_results <- c(pre_results, post_results)

assertion_descriptions <- c(
    "Input rows == 515",
    "Unique participant IDs == 515",
    "Missing participant IDs == 0",
    "Missing Environment == 0",
    "Missing Dose == 0",
    "All Environment values authorized and condition is byte-consistent with frozen group mapping",
    "All Dose values authorized",
    "Every participant maps to exactly one authorized stratum",
    "Six-stratum input counts == 95/83/101/58/103/75",
    "Assignment rows == 515",
    "Unique assigned participant IDs == 515",
    "Discovery n == 386",
    "Validation n == 129",
    "Humid-hot / Control == Discovery 71 / Validation 24",
    "Humid-hot / Short == Discovery 62 / Validation 21",
    "Humid-hot / Long == Discovery 76 / Validation 25",
    "High-pressure/high-altitude / Control == Discovery 44 / Validation 14",
    "High-pressure/high-altitude / Short == Discovery 77 / Validation 26",
    "High-pressure/high-altitude / Long == Discovery 56 / Validation 19",
    "Missing Split values == 0",
    "Split restricted to Discovery / Validation",
    "Every input participant appears exactly once",
    "No participant outside canonical input",
    "Seed == 20260925 for all rows",
    "Protocol_version == DiscoveryValidationProtocol_v1.0 for all rows",
    "Assignment metadata agrees exactly with canonical input"
)
observed <- c(
    nrow(metadata), length(unique(metadata$UniqueSampleID)), sum(missing_value(metadata$UniqueSampleID)),
    sum(missing_value(metadata$condition)), sum(missing_value(metadata$TREAT1_clean)),
    paste(unique(metadata$Condition_utf8_hex), collapse = " | "),
    paste(sort(unique(metadata$TREAT1_clean)), collapse = " | "),
    sum(!is.na(mapping_index)), paste(as.integer(input_counts), collapse = "/"),
    nrow(assignment), length(unique(assignment$UniqueSampleID)), sum(assignment$Split == "Discovery"),
    sum(assignment$Split == "Validation"),
    apply(split_counts, 1, function(z) paste(z, collapse = "/")),
    sum(missing_value(assignment$Split)), paste(sort(unique(assignment$Split)), collapse = " | "),
    sum(metadata$UniqueSampleID %in% assignment$UniqueSampleID & table(factor(assignment$UniqueSampleID, levels = metadata$UniqueSampleID)) == 1L),
    sum(!assignment$UniqueSampleID %in% metadata$UniqueSampleID),
    paste(unique(assignment$Seed), collapse = " | "),
    paste(unique(assignment$Protocol_version), collapse = " | "),
    metadata_agreement
)
expected <- c(
    "515", "515", "0", "0", "0", "e6b9bfe783ad | e9ab98e6b5b7e68b94", "control | high | low", "515",
    "95/83/101/58/103/75", "515", "515", "386", "129",
    "71/24", "62/21", "76/25", "44/14", "77/26", "56/19", "0",
    "Discovery | Validation", "515", "0", "20260925",
    "DiscoveryValidationProtocol_v1.0", "TRUE"
)
assertions <- data.frame(
    Assertion_ID = names(all_results),
    Description = assertion_descriptions,
    Observed = as.character(observed),
    Expected = expected,
    Status = ifelse(all_results, "PASS", "FAIL"),
    stringsAsFactors = FALSE
)

if (any(!all_results)) {
    stop(paste("Post-randomization assertions failed:", paste(names(all_results)[!all_results], collapse = ", ")))
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(assignment, assignment_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(assertions, assertion_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")

sha256_file <- function(path) {
    output <- system2("certutil", c("-hashfile", shQuote(normalizePath(path, winslash = "\\")), "SHA256"), stdout = TRUE, stderr = TRUE)
    compact <- gsub("[[:space:]]", "", output)
    hashes <- compact[grepl("^[0-9A-Fa-f]{64}$", compact)]
    if (length(hashes) != 1L) stop(paste("Could not obtain exactly one SHA-256 for", path))
    tolower(hashes)
}

input_sha256 <- sha256_file(input_file)
assignment_sha256 <- sha256_file(assignment_file)
created_at <- format(Sys.time(), tz = "America/Los_Angeles", usetz = TRUE)
rng <- RNGkind()
site_split <- with(assignment, table(group, Split))
site_dose_split <- with(assignment, table(group, TREAT1_clean, Split))

manifest_lines <- c(
    paste0("Protocol_version: ", protocol_version),
    paste0("Seed: ", frozen_seed),
    paste0("Canonical_input_path: ", input_file),
    paste0("Input_row_count: ", nrow(metadata)),
    paste0("Discovery_n: ", sum(assignment$Split == "Discovery")),
    paste0("Validation_n: ", sum(assignment$Split == "Validation")),
    paste0("Creation_timestamp: ", created_at),
    paste0("R_version: ", R.version.string),
    paste0("RNG_kind: ", rng[1]),
    paste0("Normal_kind: ", rng[2]),
    paste0("Sample_kind: ", rng[3]),
    "Permutation_function: base::sample(x, size = length(x), replace = FALSE)",
    "Set_seed_calls: 1",
    "Permutation_calls: 6",
    "Assignment_algorithm: canonical ASCII/UTF-8-byte ID sort; one global RNG stream; six strata in frozen order; first fixed N_validation per permutation assigned Validation; remainder Discovery",
    paste0("Canonical_input_SHA256: ", input_sha256),
    paste0("Assignment_SHA256: ", assignment_sha256),
    "Integrity_assertions: 26 PASS; 0 FAIL",
    "",
    "Six-stratum counts (Discovery/Validation):",
    paste0(strata$Stratum, ": ", split_counts[, "Discovery"], "/", split_counts[, "Validation"]),
    "",
    "Site x Split descriptive QC:",
    capture.output(print(site_split)),
    "",
    "Site x Dose x Split descriptive QC:",
    capture.output(print(site_dose_split))
)
writeLines(manifest_lines, manifest_file, useBytes = TRUE)

cat("SPLIT_EXECUTION_STATUS=SUCCESS\n")
cat("R_VERSION=", R.version.string, "\n", sep = "")
cat("RNG=", paste(rng, collapse = "/"), "\n", sep = "")
cat("SEED=", frozen_seed, "\n", sep = "")
cat("SET_SEED_CALLS=1\n")
cat("SAMPLE_CALLS=6\n")
cat("ASSERTIONS=26 PASS, 0 FAIL\n")
cat("ASSIGNMENT=515; Discovery=386; Validation=129\n")
cat("INPUT_SHA256=", input_sha256, "\n", sep = "")
cat("ASSIGNMENT_SHA256=", assignment_sha256, "\n", sep = "")
cat("CREATED_AT=", created_at, "\n", sep = "")
cat("STRATUM_COUNTS\n")
print(split_counts)
cat("SITE_SPLIT_QC\n")
print(site_split)
cat("SITE_DOSE_SPLIT_QC\n")
print(site_dose_split)
