cat("ggplot2:", as.character(if(requireNamespace("ggplot2",quietly=TRUE)) packageVersion("ggplot2") else "MISSING"), "\n")
cat("svglite:", as.character(if(requireNamespace("svglite",quietly=TRUE)) packageVersion("svglite") else "MISSING"), "\n")
cat("gridExtra:", as.character(if(requireNamespace("gridExtra",quietly=TRUE)) packageVersion("gridExtra") else "MISSING"), "\n")
