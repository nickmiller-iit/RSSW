# Notes on red sunflower seed weevil genome assembly

## Insects

Jarrad Prasifka collected larvae from ~ 10 sunflower heads. Larvae were starved for > 60 hours over a weekend. A total of 17 larvae were pooled for DNA extraction by the UIUC core facility.

## Sequencing libraries

UIUC ended up preparing 2 PacBio HiFi libraries. The first one performed poorly. They ran it twice, tweaking the run parameters but only managed to get ~701 MB (weevil_m64108e_211030_220410.hifi_reads.fastq.gz), and 1.6 Gb (weevil_m64108e_211030_220410.hifi_reads.fastq.gz) of total data on each run. Average read lengths were also a bit short: 7.8kb and 7.9 kb respectively.

They made a second library from a pool of 16 larvae, with thorough DNA cleaning (Weevil_m64108e_220407_204305.hifi_reads.fastq.gz), that performed much better, yeilding 30.1 Gb total read data and mean read length of 11.4 kb.

## Initial Assembly with flye

For an initial assembly, just used the data from the "good library". Adding the other 2 runs contributes very little in terms of extra coverage and rists adding some suspect data into the mix. Furthermore, since the 2 libraries were prepared from different pools of individuals, mixing libraries will increase the genetic variation in the assembly data.

Inital assembly was done with flye 2.8 with defaullt params for hifi data.

Basic assembly stats provided by flye:

	Total length:   2082541779
	Fragments:      47821
	Fragments N50:  98363
	Largest frg:    1740295
	Scaffolds:      88
	Mean coverage:  12

Basic stats from the Sanger assembly stats tool:

stats for flyeAssembly/assembly.fasta

	sum = 2082541779, n = 47821, ave = 43548.69, largest = 1740295
	N50 = 98363, n = 5064
	N60 = 71807, n = 7550
	N70 = 49272, n = 11046
	N80 = 33214, n = 16181
	N90 = 19720, n = 24238
	N100 = 12, n = 47821
	N_count = 8800
	Gaps = 88

So, total assembly is about 2.08 Gb. That puts is around 200Mb larger than the known genome size. Most likely, we have some redundant contigs due to genetic variation in the source material. We should be able to correct this with `purge_haplotigs` or similar tool.

Also ran a BUSCO analysis of this initial assembly (NB, takes a day or so to run), using the endopterygote database. Results are:

	C:64.1%[S:54.0%,D:10.1%],F:6.0%,M:29.9%,n:2124
	1361	Complete BUSCOs (C)
	1147	Complete and single-copy BUSCOs (S)
	214	Complete and duplicated BUSCOs (D)
	127	Fragmented BUSCOs (F)
	636	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

While far from perfect, this is no too bad for a first pass. Having about 10% duplicated BUSCOs is pretty consistent with the idea that the assembly is about 10% bigger than it should be due to redundant contigs. The ~30% missing BUSCOs is a little concerning, but we need to keep in mind that the gene finding done here is pretty quick & dirty, so there's a good chance some BUSCOs are being missed, even if they are in the assembly.



## Initial assembly with hifiasm

For comparison, trying a different assembler. Hifiasm is quick and has a been used to assemble several insect genomes.

Unfortunately my first attempt to run hifiasm failed. Because this was run via `conda run` and `make` it is not obvious what went wrong. Might come back to this later.

Update 5th Oct 2022: Did get hifiasm to run, but did so outside of Makefile etc as a test. It took 8 days, basic assembly stats were

	sum = 1360509092, n = 38974, ave = 34908.12, largest = 482041
	N50 = 39310, n = 10554
	N60 = 33998, n = 14281
	N70 = 29673, n = 18565
	N80 = 25555, n = 23496
	N90 = 20521, n = 29385
	N100 = 3151, n = 38974
	N_count = 0
	Gaps = 0

So, on the face of it, not as good as the flye assembly - we are missing about 500Mb of the genome and the N50 is lower. Suspect this is because hifiasm makes quite strong assumptions that the organism is diploid, and we have decent coverage. In our case we have a pool of individuals and low coverage.

Just to be sure, ran a BUSCO analysis with the same params as for the initial flye assembly.

	C:37.6%[S:31.5%,D:6.1%],F:11.0%,M:51.4%,n:2124
	800	Complete BUSCOs (C)
	670	Complete and single-copy BUSCOs (S)
	130	Complete and duplicated BUSCOs (D)
	234	Fragmented BUSCOs (F)
	1090	Missing BUSCOs (M)
	2124	Total BUSCO groups searched


This is substantially worse.

## Deduplication of flye assembly with redundans

Since we appear to have some "excess" sequence in our genome, try to get rid of redundant haplotigs with `redundans`. As and aside, I also tried `purge_haplotigs` but it was behaving oddly. After running redundans with just the flye assembly as input, we get the following assembly stats.

	sum = 1844871505, n = 28898, ave = 63840.80, largest = 1740295
	N50 = 115390, n = 4020
	N60 = 86115, n = 5881
	N70 = 63455, n = 8372
	N80 = 44015, n = 11870
	N90 = 28279, n = 17085
	N100 = 476, n = 28898
	N_count = 7600
	Gaps = 76
	
*NB* the estimate genome size from flow cytometry is 1.84 Gb ± 0.02. We are pretty much smack on the expected genome size here

If redundans has done what we hope it has, the reduction in genome size should result in BUSCOs that were found as duplicated in the initial assembly being shifted to the single copy category. Re-ran BUSCO analysis using identical settings as for the initial assembly:

	C:63.5%[S:54.8%,D:8.7%],F:6.2%,M:30.3%,n:2124
	1349	Complete BUSCOs (C)
	1165	Complete and single-copy BUSCOs (S)
	184	Complete and duplicated BUSCOs (D)
	132	Fragmented BUSCOs (F)
	643	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

This is not quite as big an improvement as I had hoped, in particular I would have liked to see more BUSCOs shift from the duplicated to the the single copy category.

## Deduplication of flye assembly with purge_dups

Another tool that others have had success using to deduplice insect genomes is `purge_dups`. Lets give that a try as well

Basis stats from the purged assembly:

	stats for flyePurgeDups/purged.fa
	sum = 1971099261, n = 36153, ave = 54521.04, largest = 1740295
	N50 = 106584, n = 4528
	N60 = 79419, n = 6680
	N70 = 57299, n = 9603
	N80 = 39236, n = 13785
	N90 = 24747, n = 20071
	N100 = 12, n = 36153
	N_count = 8800
	Gaps = 88

On the face of it, `purge_dups` has not done as good a job as `redundans`. Purged assembly is larger than the known assembly size, and we have more contigs and lower N50. Nevertheless, we will run a BUSCO analysis to check that the poorer basic stats aren't hiding a better peformance in reducing gene duplication.

Results of BUSCO:

	C:64.1%[S:54.7%,D:9.4%],F:6.1%,M:29.8%,n:2124
	1362	Complete BUSCOs (C)
	1162	Complete and single-copy BUSCOs (S)
	200	Complete and duplicated BUSCOs (D)
	129	Fragmented BUSCOs (F)
	633	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

Comparison for BUSCO analysis is more or less in keeping with comparison for basic assembly stats. Redundans appears to have done a slightly better job in terms of duplicated BUSCOs, although purge_dups has slightly better numbers for fragmented and missing BUSCOs.


## Removing contaminants

A blobtools analysis of the initial flye assembly identifed a number of contaminanting contigs - mostly from bacteria and "undefined" taxonomic groups. We certainly don't want these in the final assembly, and it probably makes sense to get rid of them early.

Got the contig IDs for contigs labeled as eukaryote or "no hit" from the blobtools output, and extracted the corresponding contigs from the initial flye assembly.

Basic stats for the decontaminated assembly

	stats for flyeDecon/assemblyDecon.fasta
	sum = 2061145726, n = 47311, ave = 43565.89, largest = 1740295
	N50 = 98485, n = 5009
	N60 = 71893, n = 7467
	N70 = 49350, n = 10925
	N80 = 33245, n = 16003
	N90 = 19755, n = 23969
	N100 = 12, n = 47311
	N_count = 8800
	Gaps = 88

On the face of it, removing contaminant contigs has not changed very much. This is good, in the sense that there was not a lot of contamination in the initial assembly. On the other hand, I was hoping that some of the duplicated BUSCOs might be due to contamination. Although that seems unlikely, it is still worth checking.

BUSCO results for endoterygote lineage are:

	C:63.7%[S:53.8%,D:9.9%],F:6.1%,M:30.2%,n:2124
	1353	Complete BUSCOs (C)
	1143	Complete and single-copy BUSCOs (S)
	210	Complete and duplicated BUSCOs (D)
	130	Fragmented BUSCOs (F)
	641	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

As suspected, removing contaminants has not done very much. Nevertheless, it needed to be done at some stage in the assembly process.

# Deduplication of decontaminated inital assembly

Next step is to try and get rid of redundant haplotigs using the decontaminated initial assembly as a starting point. Redundans did pretty well before, so used that.

Basic assembly stats for scaffolds.reduced.fa

	sum = 1826669513, n = 28643, ave = 63773.68, largest = 1740295
	N50 = 115391, n = 3981
	N60 = 86122, n = 5823
	N70 = 63415, n = 8290
	N80 = 43976, n = 11755
	N90 = 28250, n = 16924
	N100 = 476, n = 28643
	N_count = 7600
	Gaps = 76


The above redundans run did not use any read data for scaffolding. Out of curiosity, decided to re-run using the HiFi reads used in teh original assembly for scaffolding. This is slow, took about 6 days to run.

However, it does appear to have had a substantial impact on the assembly

	sum = 1577197296, n = 12261, ave = 128635.29, largest = 6008835
	N50 = 452285, n = 791
	N60 = 301676, n = 1219
	N70 = 195711, n = 1869
	N80 = 108685, n = 2960
	N90 = 48998, n = 5137
	N100 = 476, n = 12261
	N_count = 10184139
	Gaps = 13535

Total assembly is reduced to 1.58 Gb, this si smaller than the genome size, but could be due to collapsing some repeats. Total number of contigs with read scaffolding is less than half the number without it, and N50 is almost quadrupled.

## BUSCO analysis of deduplicated  decontaminated assemblies

Given the substantial impact on assembly stats of including the long reads for scaffolding, it would be worthwhile seeing if there is an impact on BUSCO results, especially with repsect to duplicated BUSCOs. Ran BUSCO analyses of the decontaminate, deduplicated assemblies with and without the use of long read scffolding.

### Without long read scaffolding

	C:62.9%[S:54.4%,D:8.5%],F:6.3%,M:30.8%,n:2124
	1337	Complete BUSCOs (C)
	1156	Complete and single-copy BUSCOs (S)
	181	Complete and duplicated BUSCOs (D)
	134	Fragmented BUSCOs (F)
	653	Missing BUSCOs (M)
	2124	Total BUSCO groups searched


### With long read scaffolding

	C:58.5%[S:52.5%,D:6.0%],F:5.9%,M:35.6%,n:2124
	1243	Complete BUSCOs (C)
	1116	Complete and single-copy BUSCOs (S)
	127	Complete and duplicated BUSCOs (D)
	125	Fragmented BUSCOs (F)
	756	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

This has made some difference compared to the decontaminated assembly deduplicated without long read scaffolding. We have 54 fewer duplicated BUSCOs, bring the percent duplicated down to 6%. On the other hand, we have 103 more missing BUSCOs and 94 fewer complete BUSCOS. It looks like the removed duplicated BUSCOs have been lost from the assembly (along with some complete single copy BUSCOs), rather than being converted to single copy.

So now we need to think about whether we prefer assembly with more complete BUSCOs, but slightly higher duplication, or the one with fewer complete BUSCOs, but less duplication. On balance, I think the assembly **without** long read scaffolding is preferable.


# Polishing with sort reads

** NOTE 2024-02-07 **

For downstream analysis purposes we have been using the decontaminated assembly that was deduplicated using redundans *without* using the read data. We will stick with that.

Paulina did a structural annotation using BRAKER2 and fished out part of the voltage-gated sodium channel. She did rcover some, but there appear to be abunch of internal chunks of the gene missing. I've been trying to align the parts she obtained to other voltage gated sodium channels and noticed that even in the parts that do align, there are a remarkably high number of susbtitutions compared to toher insects (including weeveils). This leads me to wonder if we might have a lot of frameshift errors in our assembly. This might also explain the high count of missing BUSCOs.

One way we might be able to fix this is by polishing the assembly with short read data. We do have plenty of that, although it comes from pools of individuals, so it is not ideal. It might be OK for fixing indels though.

## Polishing with pilon

Pilon is a pretty widely used polishing tool. Had to do some tricks to get around memory limitations. Used the pool-seq data from location B as short read data for poishing.

After 1 round of polishing, assembly stats were

	stats for polishedGenome.fasta
	sum = 1824087324, n = 28643, ave = 63683.53, largest = 1739682
	N50 = 115286, n = 3979
	N60 = 86019, n = 5821
	N70 = 63294, n = 8288
	N80 = 43899, n = 11754
	N90 = 28205, n = 16924
	N100 = 473, n = 28643
	N_count = 7600
	Gaps = 76

So, total length of assembly has decreased slightly, but bumber of contigs and number of gaps remain unchanged.

After one round of polishing, ran a BUSCO analysis to see if things have changed much.

	C:63.0%[S:54.4%,D:8.6%],F:6.1%,M:30.9%,n:2124
	1338	Complete BUSCOs (C)
	1156	Complete and single-copy BUSCOs (S)
	182	Complete and duplicated BUSCOs (D)
	130	Fragmented BUSCOs (F)
	656	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

Apparently not, the numbers are almost identical to pre-polishing (decontaminated, deduplicated without the use of the long reads). it looks like we have  lost four fragmented BUSCOs and one of which has been converted to a complete BUSCO and three of which have been lost altogether.


# Scaffolding with RNA-Seq data

It might be worth using RNA-Seq reads to scaffold. This might put some previously fragmented genes into the same scafflds, although it will only help with reasonably highly expressed genes that are represented in the RNA-Seq data.

Opted to use rascaf for this. First we align RNA-Seq reads to the genome. Opted to use the genome that was polished with pilon and aligned reads with hisat2. Then used rascaf to scaffold based on RNA-Seq reads. This is pretty speedy. Running assembly stats on the scaffolded assembly:

	sum = 1824088208, n = 28591, ave = 63799.38, largest = 1739682
	N50 = 115683, n = 3955
	N60 = 86217, n = 5790
	N70 = 63448, n = 8252
	N80 = 43976, n = 11712
	N90 = 28211, n = 16879
	N100 = 473, n = 28591
	N_count = 8484
	Gaps = 128

Again, this has made a small difference, but nothing that is likely to be a game changer. Nevertheless, we will run a BUSCO analysis to see if there have been any improvements.

	C:63.1%[S:54.6%,D:8.5%],F:6.2%,M:30.7%,n:2124
	1339	Complete BUSCOs (C)
	1159	Complete and single-copy BUSCOs (S)
	180	Complete and duplicated BUSCOs (D)
	131	Fragmented BUSCOs (F)
	654	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

Again, there have been some small changes, but nothing dramatic.

At this point, the deduplicated, polished and scaffolded genome is probably as good as we are going to get. The main shorcoming is the lage number of missing BUSCOs. It is hard to see how further wrangling of the assembly, without the addition of more high quality data, is going to make a substantial difference. We need to work with what we have at this point.
