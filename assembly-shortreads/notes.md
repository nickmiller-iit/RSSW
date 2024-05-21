title: Assembly starting with short reads

# Rationale

We have done assembly using the PacBio Hifi reads on the assumption that even at low coverage this will give us a better assembly than using short reads. The long read assembly based on BUSCO analysis is not great. Furthoremore I have not been able to find a good match to the voltage-gated sodium channel gene in the long read assembly.

An alternative would be to use the pool-seq data to produce a short read primary assembly and then scaffold using the long reads. This might be worth a try although we need to keep in mind that the pool seq data is from a large pool of indvidiauls spread over a large area.

# Initial short read assembly

Short read data were the trimmed reads previously used for Pool-Seq. Used a combined dataset of the pools from sites B and L

After some intial attempts with SPADEs, it became apparent that we don't have enough RAM. Switched to minia instead. Used the minia pipleine that prodices a best assembly over mutliple valuse of k. Even with minia, RAM was an issue. Adopted a couple of tactics to cut down the assembly problem.

 1. Filtered out reads that mapped to repeats identified by RepeatModeler from the long read assembly.
 2. Subsampled 85% of total reads. Estimated to give us about 50X coverage.

Initial testing indicated that about 45% of short reads mapped to the RepeatModeler sequences. That gives us an expected assembly size of 1.84GB * 0.55 = 1.01 Gb. However it is likley there are still some un-modelled repreats in the read data.

Basic assembly stats for the initial minia assembly:

	sum = 959772281, n = 1413682, ave = 678.92, largest = 77424
	N50 = 833, n = 304117
	N60 = 636, n = 436331
	N70 = 490, n = 609229
	N80 = 394, n = 829170
	N90 = 331, n = 1095540
	N100 = 141, n = 1413682
	N_count = 0
	Gaps = 0

Initial assembly is highly fragmented, which is unsurprising given the input data is pooled from 60 individuals, so lots of alleleic variation

# Deduplication

Because we are working with Pool-Seq data it is highly likely that we have redundant contigs due too allelec variation. Used redundans to clean that up. Stats for the reduplicated assembly were:

	sum = 548954573, n = 572047, ave = 959.63, largest = 77424
	N50 = 1325, n = 121910
	N60 = 1067, n = 168071
	N70 = 830, n = 226375
	N80 = 610, n = 303318
	N90 = 419, n = 412298
	N100 = 200, n = 572047
	N_count = 0
	Gaps = 0
	
Looks like we have removed a lot of redundant contigs. Did not use redundans to scaffold, so assembly remains highly fragmented.

# Scaffolding

The assembly is pretty fragmented. The most obvious way to improve it is to use the HiFi reads to scaffold the assembly. There are plenty of tools ou there to do this, but I had a hard time gettign some of them to rune. In the end, used NtLink, mostly because it installed and ran.

Scaffolding used the Hifi reads and the short read contigs >= 400bp (a bit over 90% of the contigs)

Stats for the scaffolded assembly are:

	sum = 859317926, n = 353693, ave = 2429.56, largest = 315274
	N50 = 12616, n = 16921
	N60 = 8463, n = 25211
	N70 = 4638, n = 38775
	N80 = 1996, n = 67705
	N90 = 730, n = 139302
	N100 = 200, n = 353693
	N_count = 318845148
	Gaps = 183658

This is still more fragmented than the HiFi assembly by about a factor of 10. We defenitly do not want to use the shrot read assembly for our population structure analysis, but maybe it can be used to find (fragments of) the para VGSC ortholog?
