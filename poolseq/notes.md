# Pool-Seq Analysis.

The goals of this project are

 1. Evaluate general levels of genetic structure in RSSW as an indicator of dispersal ability
 2. Look for evidence of pyrethroid resistance mutations.
 
Originally we planned to use MIPs, but my concern was that we would not get enough loci to detect low-moderate genetic differentiation. In the end, opted to do Pool sequencing of insects collected from 8 locations along a transect, including one site close to a field where pyrethroid resistance is a concern.

Each pool is made of equal amounts of DNA from 30 individuals.

Sequencing was whole genome shotgun sequencing done by Novogene. Number of read pairs per site was between 390 and 491 million. For site O we got an extra set of read files with about 14 million read pairs (`O_CKDN220061314-1A_HMMYMDSX5_L2_1.fq.gz` & `O_CKDN220061314-1A_HMMYMDSX5_L2_2.fq.gz`). These were not used.

Raw reads were quality-trimmed & adaptor clipped using fastp.

Paired reads from each location pool were aligned to the assembled genome produced from PacBio Hifi reads using minimap2. Used the same assembly that we used for repeat detection and masking (deduplicated with redundans, but no redundans scaffolding). During alignment, PCR duplicates were tagged and removed.

Following the initial aligment, alignments were filtered to remove reads with low mapping qualities, improperly paired reads and reads in known repeats.
