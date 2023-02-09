#!/usr/bin/env Rscript

# This script prepares a poolfstat::pooldata object from a VCF file
# and saves it as an RDS file. There are 2 steps prior to saving the pooldata: 
# 1) Read the VCF file and create an initial pooldata object
# 2) Thin the pooldata object so that SNPs are >= the specified minimum distance apart.
#
# Everything is hard coded, due to lazyness / only need to run this once.

# Some setup stuff

set.seed(20230208) # to ensure repeatability

library(poolfstat)
source("thinPooldata.R") # code for thinning functions

vcfFile <- "includedSites.vcf"
outFile <- "pooldata.dat"
min.distance <- 1000 # min distance between sites
min.cov <- 10 # min coverage to include a site
pool.names <- c("B", "D", "H", "K", "L", "O", "S", "T") # order as in VCF file
pool.sizes <- rep(60, 8) # 30 diploids per pool

cat("######################################################\n")
cat(paste("Reading data from", vcfFile, "\n"))
cat(paste("minimum coverage =", min.cov, "\n"))


p <- vcf2pooldata(vcf.file = vcfFile, 
                  min.cov.per.pool = min.cov, 
                  poolnames = pool.names, 
                  poolsizes = pool.sizes)


cat("######################################################\n")

cat(paste("Thinning pool data, minimum distance between SNPS =", min.distance, "\n"))

p2 <- thin.pooldata(p, min.distance = min.distance)

cat("######################################################\n")

cat(paste("Writing pooldata object to file", outFile, "\n"))

saveRDS(p2,
        file = outFile)