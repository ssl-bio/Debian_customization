## Check the latest version and its requirement at: https://www.bioconductor.org/install/
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(version = "3.20")
