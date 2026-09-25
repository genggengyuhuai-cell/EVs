# v2.1: binary detection logistic models; never abundance limma.
# Separation policy: record NA/status; no penalized fallback or fabricated estimate.

arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
ROOT_DIR <- if (length(arg) == 1L) {
    dirname(normalizePath(sub("^--file=", "", arg)))
} else {
    getwd()
}

source(file.path(ROOT_DIR, "v21_common.R"))

v21_packages(c(
    "detectseparation",
    "dplyr",
    "ggplot2",
    "svglite",
    "ragg"
))

library(ggplot2)

FDR_CUTOFF <- 0.05
AGE_SEX_MIN_COMPLETE <- 0.90

INPUT_DIR <- file.path(ROOT_DIR, "detection_pattern")
OUTPUT_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "10_detection_pattern_analysis"
)

files <- file.path(
    INPUT_DIR,
    c(
        "binary_detection_matrix.csv.gz",
        "detection_metadata.csv",
        "protein_detection_rates_by_exposure.csv",
        "detection_pattern_membership.csv"
    )
)

binary <- v21_read(
    files[1],
    "PG.ProteinGroups",
    "PG.ProteinGroups"
)

metadata <- v21_read(
    files[2],
    c("UniqueSampleID", "TREAT1_clean", "condition"),
    "UniqueSampleID",
    TRUE
)

rates <- v21_read(
    files[3],
    c(
        "PG.ProteinGroups",
        paste0(c("Control", "Short", "Long"), "_detection_rate"),
        "In_detection_analysis_universe"
    ),
    "PG.ProteinGroups"
)

membership <- v21_read(
    files[4],
    c(
        "PG.ProteinGroups",
        "Detection_pattern",
        "Target_threshold"
    )
)

mother_ids <- binary$PG.ProteinGroups

v21_ids(
    names(binary)[-1],
    "Binary matrix sample IDs"
)

metadata <- v21_match(
    names(binary)[-1],
    metadata,
    "Detection metadata"
)

if (!setequal(mother_ids, rates$PG.ProteinGroups)) {
    stop("Detection rate/matrix protein-ID mismatch.")
}

rates <- rates[
    match(mother_ids, rates$PG.ProteinGroups),
    ,
    drop = FALSE
]

# -------------------------------------------------------------------------
# Strict Python -> R compatibility parsing for the frozen detection universe.
#
# Upstream Python writes:
#   True
#   False
#
# v21_read() imports this column as character under the current runtime.
# Parse ONLY these two explicit tokens. Unknown/malformed values remain fatal.
# This changes representation only; it does NOT redefine the universe.
# -------------------------------------------------------------------------

universe_flag_raw <- trimws(
    as.character(rates$In_detection_analysis_universe)
)

if (
    anyNA(universe_flag_raw) ||
    !all(universe_flag_raw %in% c("True", "False"))
) {
    bad_values <- unique(
        universe_flag_raw[
            is.na(universe_flag_raw) |
                !universe_flag_raw %in% c("True", "False")
        ]
    )

    stop(
        paste0(
            "In_detection_analysis_universe must contain only ",
            "Python-exported True/False values. Invalid value(s): ",
            paste(bad_values, collapse = ", ")
        )
    )
}

rates$In_detection_analysis_universe <-
    universe_flag_raw == "True"

y <- as.matrix(binary[-1])

if (
    !is.numeric(y) ||
    anyNA(y) ||
    !all(y %in% c(0, 1))
) {
    stop("Binary input must contain only 0 or 1.")
}

if (
    anyNA(metadata$TREAT1_clean) ||
    !all(metadata$TREAT1_clean %in% EXPOSURE_LEVELS) ||
    !all(EXPOSURE_LEVELS %in% metadata$TREAT1_clean)
) {
    stop("Invalid exposure groups.")
}

# Verify rates against binary phenotype to prevent mixing
# independently regenerated files.
for (i in seq_along(EXPOSURE_LEVELS)) {

    computed <- rowMeans(
        y[
            ,
            metadata$TREAT1_clean == EXPOSURE_LEVELS[i],
            drop = FALSE
        ]
    )

    saved <- rates[[
        paste0(
            c("Control", "Short", "Long")[i],
            "_detection_rate"
        )
    ]]

    if (
        !is.numeric(saved) ||
        anyNA(saved) ||
        any(abs(computed - saved) > 1e-10)
    ) {
        stop("Detection rates disagree with binary matrix.")
    }
}

# -------------------------------------------------------------------------
# Frozen detection-analysis universe.
#
# Scientific rule:
# max(Control, Short, Long detection rate) >= 0.60
#
# The stored upstream flag MUST agree row-for-row with this independent
# R-side reconstruction.
# -------------------------------------------------------------------------

rate_columns <- paste0(
    c("Control", "Short", "Long"),
    "_detection_rate"
)

expected_universe <- apply(
    rates[, rate_columns, drop = FALSE],
    1,
    max
) >= 0.60

if (
    !is.logical(rates$In_detection_analysis_universe) ||
    anyNA(rates$In_detection_analysis_universe) ||
    length(rates$In_detection_analysis_universe) !=
        length(expected_universe) ||
    any(
        rates$In_detection_analysis_universe !=
            expected_universe
    )
) {
    stop(
        paste0(
            "Detection-analysis universe must equal ",
            "max(Control, Short, Long detection rate) >= 0.60."
        )
    )
}

analysis_index <- which(
    rates$In_detection_analysis_universe
)

if (!length(analysis_index)) {
    stop("Detection-analysis universe is empty.")
}

ids <- mother_ids[analysis_index]

y <- y[
    analysis_index,
    ,
    drop = FALSE
]

analysis_rates <- rates[
    analysis_index,
    ,
    drop = FALSE
]

primary_membership <- membership[
    membership$Target_threshold == 0.70,
    ,
    drop = FALSE
]

v21_ids(
    primary_membership$PG.ProteinGroups,
    "70% pattern IDs"
)

if (
    !setequal(
        mother_ids,
        primary_membership$PG.ProteinGroups
    )
) {
    stop("70% pattern protein-ID mismatch.")
}

pattern <- primary_membership$Detection_pattern[
    match(
        ids,
        primary_membership$PG.ProteinGroups
    )
]

restricted <- c(
    "Control_specific",
    "Short_specific",
    "Long_specific",
    "Control_Short_enriched",
    "Control_Long_enriched",
    "Short_Long_enriched"
)

# Classification-only annotation:
# union of restricted classes at 70% and 60%.
candidate <- ids %in%
    membership$PG.ProteinGroups[
        membership$Target_threshold %in% c(0.70, 0.60) &
            membership$Detection_pattern %in% restricted
    ]

model_meta <- data.frame(
    exposure = factor(
        metadata$TREAT1_clean,
        levels = EXPOSURE_LEVELS
    ),
    environment = factor(metadata$condition)
)

valid_token <- function(x) {
    !is.na(x) &
        nzchar(trimws(x)) &
        !tolower(trimws(x)) %in%
            c("unknown", "na", "missing")
}

# Token values stay unchanged in the source;
# exclusions for models are explicit below.
valid_env <- valid_token(metadata$condition)

date_field <- v21_alias(
    metadata,
    c(
        "进样时间",
        "MS_batch_proxy",
        "acquisition_date",
        "run_date"
    ),
    "acquisition date"
)

date_ok <- rep(FALSE, nrow(metadata))

if (!is.na(date_field)) {

    date_ok <- valid_token(
        metadata[[date_field]]
    )

    model_meta$acquisition_date <- factor(
        metadata[[date_field]]
    )
}

age_field <- v21_alias(
    metadata,
    c("Age", "age", "年龄"),
    "age"
)

sex_field <- v21_alias(
    metadata,
    c(
        "Sex",
        "sex",
        "Gender",
        "gender",
        "性别"
    ),
    "sex"
)

age_sex_ok <- rep(
    FALSE,
    nrow(metadata)
)

if (
    !is.na(age_field) &&
    !is.na(sex_field)
) {

    age <- suppressWarnings(
        as.numeric(metadata[[age_field]])
    )

    age_sex_ok <-
        valid_env &
        is.finite(age) &
        age >= 0 &
        valid_token(metadata[[sex_field]])

    model_meta$age <- age
    model_meta$sex <- factor(
        metadata[[sex_field]]
    )
}

age_sex_enabled <-
    mean(age_sex_ok) >= AGE_SEX_MIN_COMPLETE

contrasts <- names(CONTRAST_LABELS)

empty_rows <- function(
    status,
    n,
    detail = "",
    zero_cells = NA
) {

    data.frame(
        Contrast = contrasts,
        logOR = NA_real_,
        OR = NA_real_,
        SE = NA_real_,
        CI_low_OR = NA_real_,
        CI_high_OR = NA_real_,
        P = NA_real_,
        N_samples = n,
        Zero_cells = zero_cells,
        Model_status = status,
        Detail = detail
    )
}

fit_one <- function(
    response,
    data,
    formula,
    keep
) {

    d <- droplevels(
        data[
            keep,
            ,
            drop = FALSE
        ]
    )

    d$detected <- response[keep]
    n <- nrow(d)

    if (
        !n ||
        !all(
            EXPOSURE_LEVELS %in%
                as.character(d$exposure)
        )
    ) {
        return(
            empty_rows(
                "missing_exposure_group",
                n
            )
        )
    }

    cells <- table(
        factor(
            d$exposure,
            levels = EXPOSURE_LEVELS
        ),
        factor(
            d$detected,
            levels = 0:1
        )
    )

    zero <- any(cells == 0L)

    if (
        length(unique(d$detected)) < 2L
    ) {
        return(
            empty_rows(
                "constant_detection",
                n,
                zero_cells = zero
            )
        )
    }

    design <- tryCatch(
        model.matrix(
            formula,
            data = d
        ),
        error = function(e) e
    )

    if (inherits(design, "error")) {
        return(
            empty_rows(
                "design_error",
                n,
                conditionMessage(design),
                zero
            )
        )
    }

    if (
        anyNA(design) ||
        nrow(design) != n
    ) {
        return(
            empty_rows(
                "missing_covariates",
                n,
                zero_cells = zero
            )
        )
    }

    if (
        qr(design)$rank < ncol(design)
    ) {
        return(
            empty_rows(
                "rank_deficient_design",
                n,
                zero_cells = zero
            )
        )
    }

    warnings <- character()

    result <- tryCatch(
        withCallingHandlers(
            {

                sep <- glm(
                    formula,
                    data = d,
                    family = binomial("logit"),
                    na.action = na.fail,
                    method =
                        detectseparation::detect_separation
                )

                if (anyNA(coef(sep))) {
                    return(
                        empty_rows(
                            "separation_check_failed",
                            n,
                            zero_cells = zero
                        )
                    )
                }

                if (
                    any(
                        is.infinite(
                            coef(sep)
                        )
                    )
                ) {
                    return(
                        empty_rows(
                            "separation_nonfinite_MLE",
                            n,
                            zero_cells = zero
                        )
                    )
                }

                fit <- glm(
                    formula,
                    data = d,
                    family = binomial("logit"),
                    na.action = na.fail,
                    control =
                        glm.control(maxit = 100)
                )

                if (!isTRUE(fit$converged)) {
                    return(
                        empty_rows(
                            "nonconverged",
                            n,
                            zero_cells = zero
                        )
                    )
                }

                beta <- coef(fit)
                covariance <- vcov(fit)

                if (
                    any(!is.finite(beta)) ||
                    any(!is.finite(covariance))
                ) {
                    return(
                        empty_rows(
                            "nonestimable_coefficients",
                            n,
                            zero_cells = zero
                        )
                    )
                }

                if (
                    !all(
                        c(
                            "exposurelow",
                            "exposurehigh"
                        ) %in% names(beta)
                    )
                ) {
                    return(
                        empty_rows(
                            "missing_exposure_coefficients",
                            n,
                            zero_cells = zero
                        )
                    )
                }

                L <- matrix(
                    0,
                    nrow = 3,
                    ncol = length(beta),
                    dimnames = list(
                        contrasts,
                        names(beta)
                    )
                )

                L[
                    "Low_vs_Control",
                    "exposurelow"
                ] <- 1

                L[
                    "High_vs_Control",
                    "exposurehigh"
                ] <- 1

                L[
                    "High_vs_Low",
                    c(
                        "exposurelow",
                        "exposurehigh"
                    )
                ] <- c(-1, 1)

                estimate <- as.vector(
                    L %*% beta
                )

                variance <- diag(
                    L %*%
                        covariance %*%
                        t(L)
                )

                se <- sqrt(
                    pmax(
                        variance,
                        0
                    )
                )

                result <- empty_rows(
                    if (zero) {
                        "ok_zero_cells"
                    } else {
                        "ok"
                    },
                    n,
                    zero_cells = zero
                )

                valid <-
                    is.finite(estimate) &
                    is.finite(se) &
                    se > 0 &
                    variance > 0

                result$Model_status[
                    !valid
                ] <- "nonestimable_contrast"

                result$logOR[valid] <-
                    estimate[valid]

                result$SE[valid] <-
                    se[valid]

                result$P[valid] <-
                    2 * pnorm(
                        abs(
                            estimate[valid] /
                                se[valid]
                        ),
                        lower.tail = FALSE
                    )

                result$OR[valid] <-
                    exp(
                        estimate[valid]
                    )

                result$CI_low_OR[valid] <-
                    exp(
                        estimate[valid] -
                            qnorm(0.975) *
                                se[valid]
                    )

                result$CI_high_OR[valid] <-
                    exp(
                        estimate[valid] +
                            qnorm(0.975) *
                                se[valid]
                    )

                overflow <-
                    valid &
                    (
                        !is.finite(result$OR) |
                        !is.finite(
                            result$CI_high_OR
                        ) |
                        result$OR == 0
                    )

                result[
                    overflow,
                    c(
                        "logOR",
                        "OR",
                        "SE",
                        "CI_low_OR",
                        "CI_high_OR",
                        "P"
                    )
                ] <- NA_real_

                result$Model_status[
                    overflow
                ] <- "numerical_overflow"

                result
            },
            warning = function(w) {

                warnings <<- c(
                    warnings,
                    conditionMessage(w)
                )

                invokeRestart(
                    "muffleWarning"
                )
            }
        ),
        error = function(e) {
            empty_rows(
                "model_failure",
                n,
                conditionMessage(e),
                zero
            )
        }
    )

    if (length(warnings)) {

        result[
            ,
            c(
                "logOR",
                "OR",
                "SE",
                "CI_low_OR",
                "CI_high_OR",
                "P"
            )
        ] <- NA_real_

        result$Model_status <-
            "fit_warning_not_reported"

        result$Detail <-
            paste(
                unique(warnings),
                collapse = " | "
            )
    }

    result
}

plans <- list(

    Primary = list(
        formula =
            detected ~ exposure + environment,
        keep =
            rep(TRUE, nrow(metadata)),
        enabled =
            all(valid_env),
        skip =
            "missing_environment"
    ),

    Acquisition = list(
        formula =
            detected ~
                exposure +
                environment +
                acquisition_date,
        keep =
            valid_env & date_ok,
        enabled =
            !is.na(date_field),
        skip =
            "acquisition_field_absent"
    ),

    Acquisition_matched_primary = list(
        formula =
            detected ~ exposure + environment,
        keep =
            valid_env & date_ok,
        enabled =
            !is.na(date_field),
        skip =
            "acquisition_field_absent"
    ),

    Age_sex = list(
        formula =
            detected ~
                exposure +
                environment +
                age +
                sex,
        keep =
            age_sex_ok,
        enabled =
            age_sex_enabled,
        skip =
            "age_sex_absent_or_below_90pct_complete"
    )
)

all_results <- list()

OUTPUT_DIR <- v21_output(
    OUTPUT_DIR
)

for (model in names(plans)) {

    plan <- plans[[model]]

    per_protein <- vector(
        "list",
        length(ids)
    )

    for (i in seq_along(ids)) {

        tab <- if (!plan$enabled) {

            empty_rows(
                plan$skip,
                sum(plan$keep)
            )

        } else {

            fit_one(
                y[i, ],
                model_meta,
                plan$formula,
                plan$keep
            )
        }

        tab$PG.ProteinGroups <- ids[i]
        tab$Model <- model

        per_protein[[i]] <- tab
    }

    tab <- dplyr::bind_rows(
        per_protein
    )

    tab$FDR <- NA_real_

    # Family is the fixed >=60% detection-analysis
    # universe for every contrast.
    #
    # Non-estimable rows keep NA;
    # n fixes BH to the complete universe.
    for (contrast in contrasts) {

        ix <- which(
            tab$Contrast == contrast &
                is.finite(tab$P)
        )

        tab$FDR[ix] <- p.adjust(
            tab$P[ix],
            method = "BH",
            n = length(ids)
        )
    }

    all_results[[model]] <- tab
}

primary <- all_results[["Primary"]]

robustness <- data.frame(
    PG.ProteinGroups =
        primary$PG.ProteinGroups,
    Contrast =
        primary$Contrast
)

index <- match(
    robustness$PG.ProteinGroups,
    ids
)

robustness$Detection_pattern <-
    pattern[index]

robustness$Restricted_candidate_60_or_70 <-
    candidate[index]

for (name in rate_columns) {
    robustness[[name]] <-
        analysis_rates[[name]][index]
}

robustness$In_detection_analysis_universe <-
    TRUE

for (model in names(all_results)) {

    table <- all_results[[model]]

    key <- paste(
        table$PG.ProteinGroups,
        table$Contrast,
        sep = "\r"
    )

    order <- match(
        paste(
            robustness$PG.ProteinGroups,
            robustness$Contrast,
            sep = "\r"
        ),
        key
    )

    prefix <- if (
        model == "Acquisition"
    ) {
        "Acquisition_adjusted"
    } else {
        model
    }

    for (
        column in c(
            "logOR",
            "OR",
            "SE",
            "P",
            "FDR",
            "Model_status",
            "N_samples"
        )
    ) {

        robustness[[
            paste0(
                prefix,
                "_",
                column
            )
        ]] <- table[[column]][order]
    }
}

finite <-
    is.finite(
        robustness$Primary_logOR
    ) &
    is.finite(
        robustness$Acquisition_adjusted_logOR
    )

robustness$Direction_concordant <- NA

robustness$Direction_concordant[
    finite
] <-
    sign(
        robustness$Primary_logOR[
            finite
        ]
    ) ==
    sign(
        robustness$Acquisition_adjusted_logOR[
            finite
        ]
    )

# Confounding flag uses the SAME cohort,
# avoiding attributing sample loss to adjustment.
matched <-
    is.finite(
        robustness$Acquisition_matched_primary_logOR
    ) &
    is.finite(
        robustness$Acquisition_adjusted_logOR
    ) &
    is.finite(
        robustness$Acquisition_matched_primary_FDR
    ) &
    is.finite(
        robustness$Acquisition_adjusted_FDR
    )

robustness$Acquisition_sensitive <- NA

robustness$Acquisition_sensitive[
    matched
] <-
    sign(
        robustness$Acquisition_matched_primary_logOR[
            matched
        ]
    ) !=
    sign(
        robustness$Acquisition_adjusted_logOR[
            matched
        ]
    ) |
    xor(
        robustness$Acquisition_matched_primary_FDR[
            matched
        ] < FDR_CUTOFF,
        robustness$Acquisition_adjusted_FDR[
            matched
        ] < FDR_CUTOFF
    )

robustness$Model_status <- paste0(
    "Primary:",
    robustness$Primary_Model_status,
    "; Acquisition:",
    robustness$Acquisition_adjusted_Model_status
)

v21_write(
    primary,
    file.path(
        OUTPUT_DIR,
        "detection_primary_results.csv"
    )
)

v21_write(
    dplyr::bind_rows(
        all_results[-1]
    ),
    file.path(
        OUTPUT_DIR,
        "detection_sensitivity_results.csv"
    )
)

v21_write(
    robustness,
    file.path(
        OUTPUT_DIR,
        "detection_robustness.csv"
    )
)

# Display estimability separately from estimated effects;
# failures are never zeros.
FIG_DIR <- file.path(
    OUTPUT_DIR,
    "figures_nature_v2.2"
)

MODEL_LABELS <- c(
    Primary =
        "Primary detection model",
    Acquisition =
        "Acquisition-date sensitivity model",
    Acquisition_matched_primary =
        "Acquisition-date-matched primary model",
    Age_sex =
        "Age/sex sensitivity model"
)

for (model in names(all_results)) {

    for (contrast in contrasts) {

        tab <- all_results[[model]]

        tab <- tab[
            tab$Contrast == contrast,
            ,
            drop = FALSE
        ]

        shown <- dplyr::count(
            tab,
            Model_status,
            name = "N"
        )

        shown$Status_label <- gsub(
            "_",
            " ",
            shown$Model_status,
            fixed = TRUE
        )

        figure_stem <- paste0(
            "Figure_08_detection_",
            v22_slug(
                CONTRAST_LABELS[[contrast]]
            )
        )

        p <- ggplot(
            shown,
            aes(
                reorder(Status_label, N),
                N
            )
        ) +
            geom_col(
                fill = "#3178A5",
                width = 0.65
            ) +
            coord_flip() +
            labs(
                x = NULL,
                y = "Protein groups",
                title = paste(
                    MODEL_LABELS[[model]],
                    CONTRAST_LABELS[[contrast]],
                    sep = ": "
                ),
                subtitle =
                    paste0(
                        "Model status across the ",
                        ">=60% detection-analysis universe"
                    )
            )

        v21_save(
            p,
            FIG_DIR,
            paste0(
                figure_stem,
                "_model_status_",
                v22_slug(model)
            ),
            shown
        )
    }
}

for (contrast in contrasts) {

    figure_stem <- paste0(
        "Figure_08_detection_",
        v22_slug(
            CONTRAST_LABELS[[contrast]]
        )
    )

    tab <- primary[
        primary$Contrast == contrast,
        ,
        drop = FALSE
    ]

    shown <- tab[
        is.finite(tab$logOR) &
            is.finite(tab$SE) &
            is.finite(tab$FDR),
        ,
        drop = FALSE
    ]

    shown <- head(
        shown[
            order(shown$FDR),
            ,
            drop = FALSE
        ],
        20
    )

    if (nrow(shown)) {

        shown$Protein_label <- factor(
            shown$PG.ProteinGroups,
            levels = rev(
                shown$PG.ProteinGroups
            )
        )

        shown$Lower <-
            shown$logOR -
            qnorm(0.975) *
                shown$SE

        shown$Upper <-
            shown$logOR +
            qnorm(0.975) *
                shown$SE

        p <- ggplot(
            shown,
            aes(
                logOR,
                Protein_label
            )
        ) +
            geom_vline(
                xintercept = 0,
                linetype = 2,
                linewidth = 0.35
            ) +
            geom_segment(
                aes(
                    x = Lower,
                    xend = Upper,
                    yend = Protein_label
                ),
                linewidth = 0.4
            ) +
            geom_point(
                colour = "#3178A5",
                size = 1.8
            ) +
            labs(
                x =
                    "Log odds ratio (95% Wald interval)",
                y = NULL,
                title = paste(
                    "Detection-model estimates:",
                    CONTRAST_LABELS[[contrast]]
                ),
                subtitle =
                    paste0(
                        "Detection model: up to 20 ",
                        "estimable proteins ranked by BH FDR"
                    )
            )

        v21_save(
            p,
            FIG_DIR,
            paste0(
                figure_stem,
                "_effect_CI"
            ),
            shown,
            height_mm = 160
        )
    }

    shown <- robustness[
        robustness$Contrast == contrast &
            is.finite(
                robustness$Acquisition_matched_primary_logOR
            ) &
            is.finite(
                robustness$Acquisition_adjusted_logOR
            ),
        ,
        drop = FALSE
    ]

    if (nrow(shown)) {

        p <- ggplot(
            shown,
            aes(
                Acquisition_matched_primary_logOR,
                Acquisition_adjusted_logOR
            )
        ) +
            geom_abline(
                slope = 1,
                intercept = 0,
                linetype = 2,
                linewidth = 0.35
            ) +
            geom_point(
                colour = "#3178A5",
                size = 1.2,
                alpha = 0.55
            ) +
            coord_equal() +
            labs(
                x =
                    paste0(
                        "Acquisition-date-matched ",
                        "primary log odds ratio"
                    ),
                y =
                    paste0(
                        "Acquisition-date-adjusted ",
                        "log odds ratio"
                    ),
                title = paste(
                    "Acquisition-date sensitivity:",
                    CONTRAST_LABELS[[contrast]]
                ),
                subtitle =
                    paste0(
                        ">=60% detection-analysis universe; ",
                        "same acquisition-eligible cohort"
                    )
            )

        v21_save(
            p,
            FIG_DIR,
            paste0(
                figure_stem,
                "_acquisition_date_sensitivity"
            ),
            shown
        )
    }
}

selection <- dplyr::bind_rows(
    lapply(
        names(plans),
        function(name) {

            data.frame(
                Model = name,
                UniqueSampleID =
                    metadata$UniqueSampleID,
                Included =
                    plans[[name]]$keep &
                    plans[[name]]$enabled,
                Environment_raw =
                    metadata$condition,
                Acquisition_raw =
                    if (!is.na(date_field)) {
                        metadata[[date_field]]
                    } else {
                        NA_character_
                    },
                Age_raw =
                    if (!is.na(age_field)) {
                        metadata[[age_field]]
                    } else {
                        NA_character_
                    },
                Sex_raw =
                    if (!is.na(sex_field)) {
                        metadata[[sex_field]]
                    } else {
                        NA_character_
                    }
            )
        }
    )
)

v21_write(
    selection,
    file.path(
        OUTPUT_DIR,
        "model_sample_inclusion.csv"
    )
)

v21_write(
    dplyr::count(
        dplyr::bind_rows(
            all_results
        ),
        Model,
        Contrast,
        Model_status
    ),
    file.path(
        OUTPUT_DIR,
        "model_status_summary.csv"
    )
)

v21_provenance(
    OUTPUT_DIR,
    c(
        files,
        file.path(
            ROOT_DIR,
            "08_detection_pattern_analysis.R"
        )
    ),
    c(
        primary_model =
            "detected ~ exposure + environment",
        estimator =
            "binomial logit MLE",
        separation =
            "detectseparation; NA/status, no fallback",
        detection_universe =
            paste0(
                "max(Control, Short, Long ",
                "detection rate) >=0.60"
            ),
        FDR =
            paste0(
                "BH per model/contrast; ",
                "n=detection-analysis universe"
            ),
        classification_rule =
            paste0(
                "restricted at 60% or 70%; ",
                "other <20%; classification only"
            ),
        age_sex_min_complete =
            AGE_SEX_MIN_COMPLETE,
        date_field =
            date_field,
        age_field =
            age_field,
        sex_field =
            sex_field
    ),
    "detectseparation"
)

writeLines(
    c(
        "# Detection models v2.1 — NOT limma and NOT quantitative abundance",
        "Phenotype: finite raw quantity >0 =>1, otherwise 0. The upstream mother table retains all proteins.",
        "Model universe: max(Control, Short, Long detection rate) >=60%; lower-rate proteins are not modelled.",
        "Primary: detected ~ exposure + environment; standard maximum likelihood binomial logit.",
        "Separation is checked before estimation using detectseparation; no penalized fallback.",
        "Constant outcomes, separation, aliased designs, warnings/failures produce NA and explicit status.",
        "Contrasts use coefficient covariance; Wald normal P and 95% OR intervals. No pseudo-counts.",
        "BH: each model and contrast separately, n=the complete >=60% detection-analysis universe; failures keep NA.",
        "The <20% rule is used only for restricted-pattern classification and never for universe retention.",
        "Acquisition model uses eligible complete metadata; rank-deficient designs are reported, not altered.",
        "Age/sex model runs only when both fields exist and at least 90% have usable joint metadata.",
        "Literal Unknown/NA/missing values are recorded, excluded for model eligibility; numeric zero is not missing.",
        "Acquisition_sensitive: sign reversal OR crossing BH 0.05 vs primary on the SAME acquisition-eligible cohort.",
        "This is a diagnostic flag, not proof of technical confounding. Full-cohort direction concordance is separate.",
        "Observational association, not biological absence or causal exposure effect.",
        "Method reference: https://github.com/ikosmidis/detectseparation"
    ),
    file.path(
        OUTPUT_DIR,
        "README_METHODS.md"
    )
)