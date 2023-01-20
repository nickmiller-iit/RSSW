# Pool-Seq Analysis.

The goals of this project are

 1. Evaluate general levels of genetic structure in RSSW as an indicator of dispersal ability
 2. Look for evidence of pyrethroid resistance mutations.
 
Originally we planned to use MIPs, but my concern was that we would not get enough loci to detect low-moderate genetic differentiation. In the end, opted to do Pool sequencing of insects collected from 8 locations along a transect, including one site close to a field where pyrethroid resistance is a concern.

Each pool is made of equal amounts of DNA from 30 individuals.

Sequencing was whole genome shotgun sequencing done by Novogene. Number of read pairs per site was between 390 and 491 million. For site O we got an extra set of read files with about 14 million read pairs (`O_CKDN220061314-1A_HMMYMDSX5_L2_1.fq.gz` & `O_CKDN220061314-1A_HMMYMDSX5_L2_2.fq.gz`). These were not used.


## Read mapping

Raw reads were quality-trimmed & adaptor clipped using fastp.

Paired reads from each location pool were aligned to the assembled genome produced from PacBio Hifi reads using minimap2. Used the same assembly that we used for repeat detection and masking (deduplicated with redundans, but no redundans scaffolding). During alignment, PCR duplicates were tagged and removed.

Following the initial aligment, alignments were filtered to remove reads with low mapping qualities, improperly paired reads and reads in known repeats.


## Variant calling

We want to find SNPs for 2 main purposes

 1. Measuring genetic differentiation between samples
 2. Eventually, finding SNPs in the sodium channel gene that could relate to resistance.
 
The initial focus is on differentiation. There are two steps to this. The `poolfstat` R package will compute *F~ST~* from pool seq data, but we don't want to feed it a load of garbage, we want to find legit SNPs first.

The are a number of tools that can be used to call SNPs and estimate their frequencies from pool seq data, several were benchmarked by Guirao-Rico & González (2021). Some will handle multiple pools, others will only deal with a single sample. That probably doesn't matter for differentiation purposes as `poolfstat` just needs a VCF with read counts of the alleles at each SNP. We can use any of the SNP callers to get a list of polymophic sites and generate the VCF for just those sites using `bcftools`.

### MAPGD

Performed well in benchmarking. Calls SNPs and estimates sample allele frequencies. Can handle multiple samples, but does not advertize that fact. Starting input is a pileup fule produced with `samtools mpileup`. The pileup file does not support giving identifiers to samples. That's not a big deal as we only need find the SNP sites. The VCF file for `poolfstat` can still include sample identifiers.

MAPGD is not exactly speedy, nor is generating the mplileup file. Together took about 24 hours to run - not much opportunuty to run in parallel.

Following the Guirao-Rico & González paper, set the log-likelihood threshold to 22. This called 3,295,030 SNPS. Looking at the folded site frequency spectrum of these SNPs, it appears that MAPGD is heavily biased toward detecting SNPs with high expected heterozygosity. This may not be an issue for FST calculations (most markers from allozymes on that have been used to measure population structure have been pre-selected to cherry pick variable markers). However, stuff like estimates of pi and theta should be avoided.
