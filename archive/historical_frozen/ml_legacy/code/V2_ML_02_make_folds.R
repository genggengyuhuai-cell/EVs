# V2_ML_02_make_folds.R — Generate Discovery 386 nested CV fold assignments
# This IS executed: produces frozen fold assignments.
# No model training. No abundance matrix access.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_01_prepare.R")

library(digest)

OUT_DIR <- "descriptive/analysis_v2.0/ml"
dir.create(file.path(OUT_DIR, "folds"), showWarnings=FALSE, recursive=TRUE)
dir.create(file.path(OUT_DIR, "manifests"), showWarnings=FALSE, recursive=TRUE)

# ---- Load split ----
meta <- load_split_assignment()
disc <- meta[meta$Split == "Discovery", ]
hold <- meta[meta$Split == "Validation", ]
cat("Discovery:", nrow(disc), " Hold-out:", nrow(hold), "\n")
stopifnot(nrow(disc) == 386, nrow(hold) == 129)

# ---- Stratification variable: Environment × Group ----
disc$Strat <- paste(disc$Environment, disc$Group_v2, sep="|")
cat("Strata:\n"); print(table(disc$Strat))

# ---- Generate outer folds ----
outer_rows <- list()
inner_rows <- list()

for (rep in seq_len(V2_ML_N_REPEATS)) {
  seed <- V2_ML_SEEDS_OUTER[rep]
  set_ml_seed(seed)

  # Stratified 5-fold split within each stratum
  fold_ids <- rep(NA, nrow(disc))
  names(fold_ids) <- disc$UniqueSampleID

  for (strat in unique(disc$Strat)) {
    in_strat <- which(disc$Strat == strat)
    n_s <- length(in_strat)
    # Shuffle
    shuffled <- sample(in_strat, n_s, replace=FALSE)
    # Assign to 5 folds
    folds_assigned <- rep(seq_len(V2_ML_N_OUTER), length.out=n_s)
    fold_ids[shuffled] <- folds_assigned
  }

  disc$outer_fold <- fold_ids

  # Outer fold QA
  for (of in seq_len(V2_ML_N_OUTER)) {
    test <- disc$UniqueSampleID[disc$outer_fold == of]
    train <- disc$UniqueSampleID[disc$outer_fold != of]
    assert_no_holdout_samples(test, meta)
    assert_fold_disjoint(train, test)
  }

  # Save outer rows
  outer_rows[[rep]] <- data.frame(
    Participant_ID = disc$UniqueSampleID,
    Repeat = rep,
    Outer_fold = disc$outer_fold,
    Group = disc$Group_v2,
    Environment = disc$Environment,
    Primary_target = disc$Primary_target,
    Seed = seed,
    stringsAsFactors = FALSE
  )

  # Generate inner folds for each outer fold
  for (of in seq_len(V2_ML_N_OUTER)) {
    train_idx <- which(disc$outer_fold != of)
    train_disc <- disc[train_idx, ]
    inner_seed <- derive_inner_seed(rep, of)
    set_ml_seed(inner_seed)

    inner_fold <- rep(NA, nrow(train_disc))
    for (strat in unique(train_disc$Strat)) {
      in_strat <- which(train_disc$Strat == strat)
      n_s <- length(in_strat)
      shuffled <- sample(in_strat, n_s, replace=FALSE)
      assigned <- rep(seq_len(V2_ML_N_INNER), length.out=n_s)
      inner_fold[shuffled] <- assigned
    }

    # Also mark outer test participants
    outer_test_ids <- disc$UniqueSampleID[disc$outer_fold == of]

    # Inner rows for training participants
    inner_rows[[length(inner_rows)+1]] <- data.frame(
      Participant_ID = train_disc$UniqueSampleID,
      Repeat = rep,
      Outer_fold = of,
      Inner_fold = inner_fold,
      Role = "inner_training_or_val",
      Group = train_disc$Group_v2,
      Environment = train_disc$Environment,
      Primary_target = train_disc$Primary_target,
      stringsAsFactors = FALSE
    )
    # Outer test rows (no inner fold)
    inner_rows[[length(inner_rows)+1]] <- data.frame(
      Participant_ID = outer_test_ids,
      Repeat = rep,
      Outer_fold = of,
      Inner_fold = NA,
      Role = "outer_test",
      Group = disc$Group_v2[disc$outer_fold == of],
      Environment = disc$Environment[disc$outer_fold == of],
      Primary_target = disc$Primary_target[disc$outer_fold == of],
      stringsAsFactors = FALSE
    )
  }
}

outer_df <- do.call(rbind, outer_rows)
inner_df <- do.call(rbind, inner_rows)

write.csv(outer_df, file.path(OUT_DIR, "folds", "outer_folds.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
write.csv(inner_df, file.path(OUT_DIR, "folds", "inner_folds.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ---- Fold manifest ----
sha256_file <- function(p) digest(file=p, algo="sha256")
manifest <- data.frame(
  item=c("outer_folds_csv","inner_folds_csv","seed_repeat1","seed_repeat2",
         "seed_repeat3","n_outer","n_inner","n_repeats","stratification",
         "discovery_n","holdout_leakage"),
  value=c(sha256_file(file.path(OUT_DIR,"folds","outer_folds.csv")),
          sha256_file(file.path(OUT_DIR,"folds","inner_folds.csv")),
          as.character(V2_ML_SEEDS_OUTER[1]),
          as.character(V2_ML_SEEDS_OUTER[2]),
          as.character(V2_ML_SEEDS_OUTER[3]),
          as.character(V2_ML_N_OUTER),
          as.character(V2_ML_N_INNER),
          as.character(V2_ML_N_REPEATS),
          "Environment x Group",
          "386","0"),
  stringsAsFactors=FALSE)
write.csv(manifest, file.path(OUT_DIR,"manifests","V2_ML_FOLD_MANIFEST.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ---- Summary ----
cat("\n===== FOLD GENERATION COMPLETE =====\n")
cat("Outer fold rows:", nrow(outer_df), "(expected 386*3=1158)\n")
cat("Inner fold rows:", nrow(inner_df), "\n")
for (rep in seq_len(V2_ML_N_REPEATS)) {
  sub <- outer_df[outer_df$Repeat==rep, ]
  cat(sprintf("Repeat %d: N=%d, Control=%d, Exposure=%d\n",
              rep, nrow(sub),
              sum(sub$Primary_target=="Control"),
              sum(sub$Primary_target=="Exposure")))
}
cat("Done.\n")
