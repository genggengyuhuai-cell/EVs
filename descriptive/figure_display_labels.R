# Central display-label mapping for manuscript-facing figures.
# Analysis keys and source values remain unchanged; call these helpers only when
# constructing labels, legends, facets, annotations, or figure source exports.

ENVIRONMENT_LABELS <- c(
  "高压" = "High land",
  "High-pressure" = "High land",
  "high-pressure" = "High land",
  "High-pressure/high-altitude" = "High land",
  "High-altitude" = "High land",
  "high-altitude" = "High land",
  "高海拔" = "High land",
  "湿热" = "Hot-humid",
  "Humid-hot" = "Hot-humid",
  "humid-hot" = "Hot-humid"
)

SPLIT_LABELS <- c(
  "Discovery" = "Discovery",
  "Validation" = "Reused hold-out"
)

display_environment <- function(x) {
  y <- unname(ENVIRONMENT_LABELS[as.character(x)])
  y[is.na(y)] <- as.character(x)[is.na(y)]
  y
}

display_split <- function(x) {
  y <- unname(SPLIT_LABELS[as.character(x)])
  y[is.na(y)] <- as.character(x)[is.na(y)]
  y
}
