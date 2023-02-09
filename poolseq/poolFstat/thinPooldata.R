# Thin out a pooldata object such that no two SNPs on the same contig are less than the 
# specified distance apart


## Get the unique chromosome/scaffold/contig identifiers from a poolseq object
get.chrom.ids <- function(x){
  stopifnot(is.pooldata(x))
  return(unique(x@snp.info$Chromosome))
}

## Get a single chrom/scaffold/contig from a pooldata object

### NBB we have to work around some odd behaviour in poolfstat::pooldata.subset(). If the
### function is given a single value for snp.index (i.e. when there is only 1 SNP on the contig)
### it throws an error.
### Solution is to return FALSE in the case that there is only one SNP on the chromosome.
### Determining whether the this function returned FALSE or a pooldata object should be handled by
### the calling code.
get.chrom <- function(x, chromID){
  stopifnot(is.pooldata(x))
  stopifnot(chromID %in% x@snp.info$Chromosome)
  index <- which(x@snp.info$Chromosome == chromID)
  if(length(index) == 1){
    return(FALSE)
  }
  else{
    return(pooldata.subset(x, snp.index = index))
  }
}

## Thin a pooldata object containing a single chromosome/scaffold/contig.
## Returns a logical vector indicating which sites should be kept.

## The clustering approach used here is quite aggressive. It ensures that the chosen SNPs are
## separated by the min distance, but it also throws out a lot of SNPs because a SNP at one "end"
## of a cluster can be > than the min distance from a SNP at the other end of the cluster.
## Eg if min distance is 1000, we can have a cluster of SNPs at positions 1, 900, 1800, 2700 and
## only on SNP will be selected.

thin.chrom.clustering <- function(x, min.dist){
  stopifnot(is.pooldata(x))
  stopifnot(length(x@snp.info$Position) >= 1)
  positions <- x@snp.info$Position
  #shortcut if only one site on the chrom
  if (length(positions) == 1){
    return(TRUE)
  }
  #not strictly needed, but helpful for debugging
  names(positions) <- paste("pos", positions, sep = "_")
  d <- dist(positions, method = "manhattan")
  tr <- hclust(d, method = "single")
  grps <-cutree(tr, h = min.dist)
  #make sure we are sill in the same order we started
  stopifnot(sum(as.numeric(sub("pos_", "", names(grps))) != x@snp.info$Position) == 0)
  #logical vector for output
  out <- logical(length = length(grps))
  # for each unique value in grps, sample one position and set corresponding index to T
  for (g in unique(grps)){
     sampling.idxs <- which(grps == g)
    
    # sample() has some unhelpful behaviour here. In the case of sample(x), if x has length 1, 
    # is numeric and x >= 1, sampling via sample takes place from 1:x
    if(length(sampling.idxs) == 1){
      s <- sampling.idxs[1]
    }
    else{
      s <- sample(sampling.idxs, size = 1)
     }
    out[s] <- TRUE
  }
  return(out)
}

##
## Thins out a chromosome by scanning for positions that exceed the minimum distance
## starting from a specified position. Returns a logical vector indicating whether
## a position should be retained.
##
## NB - assumes positions are sorted in ascending order
thin.chrom.from.startpoint <- function(x, min.dist, start.at){
  # error checking
  stopifnot(is.pooldata(x))
  stopifnot(start.at %in% x@snp.info$Position)
  #special case - only one SNP on the chromosome
  if (length(x@snp.info$Position) == 1){
    return(TRUE)
  }
  out <- logical(length = length(x@snp.info$Position))
  out[which(x@snp.info$Position == start.at)] <- TRUE
  # scan forward
  idx <- which(x@snp.info$Position == start.at) + 1
  cumulative.dist <- 0
  while(idx <= length(x@snp.info$Position)){
    cumulative.dist <- cumulative.dist + (x@snp.info$Position[idx] - x@snp.info$Position[idx - 1])
    if (cumulative.dist >= min.dist){
      out[idx] <- TRUE
      cumulative.dist <- 0
    }
    idx <- idx + 1
  }
  # scan backward
  idx <- which(x@snp.info$Position == start.at) - 1
  cumulative.dist <- 0
  while(idx >= 1){
    cumulative.dist <- cumulative.dist + (x@snp.info$Position[idx + 1] - x@snp.info$Position[idx])
    if (cumulative.dist >= min.dist){
      out[idx] <- TRUE
      cumulative.dist <- 0
    }
    idx <- idx - 1
  }
  return(out)
  
  
  
}

## Thins out a chromosome by applying the scanning approach to all possible start points
## and finding the start point that returns the most sites. Where there is a tie among >1
## start site, one of the tied sites is selected at random

thin.chrom.exhaustive <- function (x, min.dist){
  num.sites <- numeric(0)
  for (pos in x@snp.info$Position){
    num.sites <- c(num.sites,
                   sum(thin.chrom.from.startpoint(x, min.dist, pos)))
  }
    max.sites <- max(num.sites)
    loc.max.sites <- which(num.sites == max.sites)
    if (length(loc.max.sites) == 1){
      return (thin.chrom.from.startpoint(x, min.dist, x@snp.info$Position[loc.max.sites]))
    }
    else{
      start.site <- x@snp.info$Position[sample(loc.max.sites, size = 1, replace = FALSE)]
      return (thin.chrom.from.startpoint(x, min.dist, start.site))
    }
}
    



## Main thinning function
thin.pooldata <- function(x, min.distance){
  stopifnot(is.pooldata(x))
  chroms <- get.chrom.ids(x)
  selections <- logical(0)
  for(c in chroms){
    #print(c) # for debug
    pl <- get.chrom(x, c)
    # Check if get.chrom returned FALSE, indicating a single SNP on the chrom
    if(is.logical(pl)){
      selections < c(selections, TRUE)
    }
    else{
      selections <- c(selections, thin.chrom.exhaustive(pl, min.distance))
    }
  }
  return(pooldata.subset(x, snp.index = which(selections)))
}