# Sodium channel gene polymorphisms

Here we are looking for polymorphisms in or near the sodium channel gene fragments we found in the short-read assembly. Decided to start a new subdir with a new set of notes and a new Makefile as things were getting a little messy.

## Strategy

 1. Align poolseq reads to the short read assembly. We only need to keep the reads that align to one of the contigs/scaffolds containg a fragment of the sodium channel gene.
 2. Use SNAPE-pooled on a merged pileup of all the samples to detect poymorphisms.
 3. Use SNAPE-pooled to get allele freqs in each pool for any polymorphic sites

## SNAPE-pooled on merged pileup

With the posterior probability set to 0.99, we get 744 SNPs in total

## SNAPE-pooled on individual samples

Pretty much a repeat of what we did of the whole genome / primary assembly. Nothing remarkable here.

## PCA

See the R notebook for details - no signs of any clustering of samples.

## PoolFsat

See the R notbook for details. No obvious evidence of outlier F~ST~s that might indicate selection.

As an aside, F~ST~ outlier methods can't really be applied here since we don't have heterozygosity at each locus.
