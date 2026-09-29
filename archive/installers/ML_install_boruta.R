# Try Posit binary repo for Windows
options(repos = c(CRAN="https://cloud.r-project.org",
                  PPM = "https://packagemanager.posit.co/cran/latest"))
# PPM binaries for R 4.3 on Windows:
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion()[c("platform","arch","os")], collapse=" ")))
install.packages(c("Boruta","fru","ranger"),
                 repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest",
                 quiet=TRUE)
cat("--- after try ---\n")
for (p in c("Boruta","fru","ranger","randomForest")) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-12s %s\n", p, v))
}
