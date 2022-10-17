# Identifying and masking repeats

We will want to do this both for annotation and for alignment and analysis of pool-seq data.

At the time of writing, we have 2 genome assemblies made with flye. Both were further deduplicated using `redundans`. One assembly was deduplicate using the input read data for scaffolding, the other did not. It is not clear at this stage which is preferable.

## Unscaffolded assembly.

First step, ran repeatmodeler on the unscaffolded, deduplicated assembly.

Next ran repeatmasker using the repeat library (fasta format) produced by repreat modeler. Ran with the optional GFF output, as we can use this to soft mask the sequence or use it derctly to exclude repeats from read mapping.

To get a sense of how much of the genome was msaked, ran basic assembly stats and on the hard masked output produced by RepeatMasker and compare the number of Ns to the unmasked assembly.

	stats for maskedNoScaff/scaffolds.reduced.fa.masked
	sum = 1826669513, n = 28643, ave = 63773.68, largest = 1740295
	N50 = 115391, n = 3981
	N60 = 86122, n = 5823
	N70 = 63415, n = 8290
	N80 = 43976, n = 11755
	N90 = 28250, n = 16924
	N100 = 476, n = 28643
	N_count = 1437239742
	Gaps = 2123396
	
Post hard masking, 78.6% of the genome is Ns, compared to 0.0004% before masking. Post maksing, the total amount of genome that is not masked (presumably non-repetitive) is 389.4 Mb. This is about the size of a reasonably compact insect genome, so it is at least credible. It would be worth running a BUSCO analysis to see how the results compare to pre masking. This will help us see if the maksing was overly agressive - expect to lose BUSCOs if so. Alternatively, masking could improve BUSCO results of the repetitive sequence is messing with Augustus gene prediction. 

Before Masking:

	C:63.5%[S:54.8%,D:8.7%],F:6.2%,M:30.3%,n:2124
	1349	Complete BUSCOs (C)
	1165	Complete and single-copy BUSCOs (S)
	184	Complete and duplicated BUSCOs (D)
	132	Fragmented BUSCOs (F)
	643	Missing BUSCOs (M)
	2124	Total BUSCO groups searched



After Masking:

	C:62.5%[S:54.5%,D:8.0%],F:6.9%,M:30.6%,n:2124
	1328	Complete BUSCOs (C)
	1158	Complete and single-copy BUSCOs (S)
	170	Complete and duplicated BUSCOs (D)
	146	Fragmented BUSCOs (F)
	650	Missing BUSCOs (M)
	2124	Total BUSCO groups searched
	
Essentially no difference. It is worth noting that running BUSCO on the masked genome was much sloer. Took about 3.5 days to run.
