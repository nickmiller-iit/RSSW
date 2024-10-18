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

## Looking for non-synonymous changes

Do any of the SNPs we have identified change the amino acid sequence of the protein fragments?

**YES!!!!** We have five non-synonymous SNPs one of with correspends neatly to the classic *kdr* mutation!!!!

The kdr mutation is (contig:position ref/var)

`contig_322045:428 G/A`

The non-kdr non-synonymous sites occur near the N-terminus of the protein
```
contig_95372:336 G/C
contig_95372:362 C/T
contig_95372:375 C/G
contig_95372:396 T/A
```
We can get the estimated frequency of the kdr mutation from the global SNAPE-pooled output

```
contig_322045   428     G       170     6       71      70      GA      1       0       0.04104
```

So, global frequency is low, 0.04.

### Location specific frequencies

We definitely want to know what the frequency of kdr is at each sample location. May as well do the other non-syn polymorphisms at the same time

Did this in an R Notebook.
