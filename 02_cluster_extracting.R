##############################################################################
## <<02_cluster_extracting.R>>

# BioC 3.3
# Created 28 July 2016
# Updated 

##############################################################################
Sys.time()
##############################################################################

library(flowCore)
library(gdata)
library(Repitools)
library(gplots)
library(ggplot2)
library(plyr)
library(reshape2)


##############################################################################
# Test arguments
##############################################################################

# rwd='/Users/gosia/Dropbox/UZH/carsten_cytof/CK_2016-06-23_01'
# path_clustering='pca1_mergingNEW_clustering.xls'
# path_clustering_labels='pca1_mergingNEW_clustering_labels.xls'
# extract_cluster='CD4'
# extract_dir='/Users/gosia/Dropbox/UZH/carsten_cytof/CK_2016-06-23_01_CD4/010_cleanfcs'

##############################################################################
# Read in the arguments
##############################################################################

args <- (commandArgs(trailingOnly = TRUE))
for (i in 1:length(args)) {
  eval(parse(text = args[[i]]))
}

print(args)

##############################################################################

setwd(rwd)

dir.create(extract_dir, recursive = TRUE)


# ------------------------------------------------------------
# define directories
# ------------------------------------------------------------

fcsDir <- "010_cleanfcs"; if( !file.exists(fcsDir) ) dir.create(fcsDir)
pcaDir <- "020_pcascores"; if( !file.exists(pcaDir) ) dir.create(pcaDir)
hmDir <- "030_heatmaps"; if( !file.exists(hmDir) ) dir.create(hmDir)

# ------------------------------------------------------------
# Load data
# ------------------------------------------------------------

# read metadata
md <- read.xls("metadata.xlsx",stringsAsFactors=FALSE)


# define FCS file names
f <- file.path(fcsDir, md$filename)
names(f) <- md$shortname


# read raw FCS files in
fcs <- lapply(f, read.FCS)



# ------------------------------------------------------------
# Load clustering data
# ------------------------------------------------------------

clust <- read.table(file.path(hmDir, path_clustering), header = TRUE, sep = "\t", as.is = TRUE)
clust <- clust[, 1]

labels <- read.table(file.path(hmDir, path_clustering_labels), header = TRUE, sep = "\t", as.is = TRUE)
labels <- labels[order(labels$cluster, decreasing = FALSE), ]
labels$label <- factor(labels$label, levels = unique(labels$label))


# ------------------------------------------------------------
# Save fcs files for a cluster to export
# ------------------------------------------------------------


nrow_fcs <- sapply(fcs, nrow)
mlab <- match(clust, labels$cluster)
clust <- labels$label[mlab]
  
clustList <- split(clust, rep(names(nrow_fcs), nrow_fcs))

writeOutCluster <- function(u,v,z, keep="CD4", outdir) {
  # u - cluster; v - flowFrame; z - original filename
  
  fn <- file.path(outdir, basename(z))
  # out <- v[u==keep, ]
  out <- v[grep(keep, u), ]
  write.FCS(out, fn)
  
}

m <- match(names(fcs), names(clustList))
clustList <- clustList[m]

dummy <- mapply(writeOutCluster, u = clustList, v = fcs, z = f, keep = extract_cluster, outdir = extract_dir)







sessionInfo()












################################
### 02_cluster_extracting done!
################################