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
