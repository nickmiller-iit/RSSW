# Looking for the putative voltage-gated sodium channel and variant sites therein

## Looking for parts of sodium channel in the BRAKER2 annotations

First step is to see what, if anything of the sodium channel we have in our braker annotations. A good start point is to use diamond to seach the BRAKER2 predicted proteins using sodium channel protein sequences from other species.

### Example sodium channel genes

To get some example sodium channel proteins, started out with the *Musca domestica* (housefly) as this is the canonical protein for kdr mutations. Got the housfly para-like voltage gated sodium channel protein from UniProt: Q94615. Then used this as a query for UniProt BLAST. Filtered the results to Curculionidae and picked example proteins from the hits. Final list of example sodium channel proteins is

Q94615: *Musca domestica* (Housefly)
A0A6J2XC81: *Sitophilus oryzae* (Rice weevil)
A0A834MPJ1: *Rhynchophorus ferrugineus* (Red palm weevil)
U4U5N9: *Dendroctonus ponderosae* (Mountain pine beetle)

### Diamond searches

Running diamond blastp with each of the example proteins produces hits to two predicted proteins:

 * jg42936.t1 1688 amino acids, scaffold = scaffold_26039 
 * jg12353.t1 1418 amino acids, scaffold = scaffold_266
 
 Running both of these protein sequences through uniprot blast and interpro scan on the web indicates that jg42936.t1 is the voltage gated sodium channel alpha subunit, whereas jg12353.t1 is a "sodium leak channel"
 
However, multiple sequence alignment to the example sodium channels looks pretty nasty, lots of divergent residues
 
### Gene model editing

Galaxy Europe (usegalaxy.eu) make it fairly painless to set up a jbrowse/Apollo instance for manual editing of gene models. We only need to deal with the scaffold on which our putative sodium channel gene is located.

Stared by making a working dir and extracting/creating:
 * scaffold_26039
 * samtools faidx index of scaffold_26039
 * Gene annotations for scaffold_26039
 * Repeat annotations for scaffold_26039
 * Aligned RNA-Seq reads for scaffold_26039
 * Bam index of aligned RNA-Seq reads for scaffold_26039
 * GFF of exonerate alignments of example sodium channel proteins to scaffold_26039
 
 **Note** Exonerate alignments were run as:
 `exonerate -E --model protein2dna:bestfit --showtargetgff yes --subopt no ../exampleChannels/A0A6J2XC81.fasta ./scaffold_26039.fasta > A0A6J2XC81.exonerate`



# UPDATE

After some playing around, it became apparent that the sodium chnnal gene pulled from the HiFi-based genome assembly was not the **para** ortholog, and that the **para** gene was missing from the assembly. Doing multiple alignments with the weevil proteins and the canonical housefly protein revealed the sodium channel gene was too divergent.

To try and recover some of the **para** gene, did another assembly based on short reads from the pool-seq data and scaffolded with Hifi reads. This produced a much more fragmented assembly, but decided to go ahead and see if we can find some fragments of the target gene.

## BLAST Results

To try and find fragments of the sodium channel used the Unip[rot sequences for the target sodium channel from rice weevil (A0A6J2XC81) and red palm weevil (A0A834MPJ1). Manually inspected results for hits with hight (>= 80%) amino acid identity.

### Rice weevil hits

The following contigs & scaffolds had high identity hits (query positions in brackets to indicate what parts of the channel we have):

	contig_80021 (1579-1775, 1433-1543, 1313-1394, 1544-1579, 1399-1432, 1757-1876)
	contig_195328 (1928-2044)
	contig_245694 (534-614)
	contig_322045 (944-1002, 1027-1074)
	scaffold_34427 (114-1195)
	contig_95372 (170-213, 132-170)
	contig_404260 (952-985)*
	scaffold_51779 (387-420)
	contig_348337 (956-985)*

* redundant with contig_322045, and lower % identity

### Palm weevil hits

	contig_80021 (1457-1568, 1337-1396, 1570-1619, 1423-1456, 1603-1799, 1781-1906)
	contig_195328 (1952-2054)
	contig_245694 (546-626)
	contig_322045 (950-1008, 1033-1080)
	scaffold_34427 (1150-1211, 1209-1226)
	contig_95372 (182-224, 143-181)
	scaffold_51779 (397-434)
	contig_348337 (962-991)


Looks like the gene is highly fragmented in this assembly, which may explain why it appears to be missing from the Hifi assembly, if there is a lot of repetitive stuff in the introns. We mostly seem to have the 5' end of the gene. I'm not sure at this stage if we have captured the sites for kdr and super-kdr, which are located at positions 1014 and 918 in housefly. However, we can't say that for sure at this point as BLAST HSPs are not gene models!

## Putting contigs in order

Based on the regions of the query sequences in the HSPs, we can start to put the contigs and scaffolds in order with respect to the VGSC gene:

 1. contig_95372
 2. scaffold_51779
 3. contig_245694
 4. contig_322045
 5. scaffold_34427
 6. contig_80021
 7. contig_195328

## Gene models from homologs

Used exonerate to align the example sequences from *Sitophilus oryzae* (Rice weevil) and *Rhynchophorus ferrugineus* (Red palm weevil) to the 7 contigs and scaffolds listed above. USED AGAT to clean up GFF output and consolidate to a single GFF3 file

## Updating models with Apollo

Imported the scaffold/contig sequences and GFF files into Galaxy EU. Set up a small jbrowse/Apollo instance to edit the models with the goal of recovering as much coding region as possible. Worked through from the N-terminus most region towards the C-terminus. Checked edits by multiple alignment with the riceweevil and red sunflower seed weevil protein sequences.

### contig_95372

 * Set translation start to (-)798
 * Set end of first intron to (-)681
 * Set start of second exon to (-)419
 * Set end of second exon to (-)290

Produces a fragment encoding 81 amino acids, corresponst to positions 132 - 212 (rice weevil) / 143 - 223 (palm weevil)

### scaffold_51779

 * Set start of first exon to (-)1680
 * Set end of first exon to (-)1511
 * Set start of second exon to (-)1215
 * Set end of second exon to (-)1093
 
**Important** Aligning the translation of this model to rice & plam weevil suggests it is not part of the same protein - too many mismatches.

### contig_245694

 * Only one exon
 * Left start of exon at 1515
 * Adjusted end of exon to 1759 to next splice site, does not affect translated sequence
 
Produces a fragment encoding 81 amino acids, corresponding to positions 534 - 614 (rice wevil) / 546 - 626 (palm weevil)
 
###  contig_322045

 * Set end of exon 1 to (-)423
 * Set start of exon 2 to (-)349

Produces a fragment of 131 amino acids, corresponding to poistions 944 - 1074 (rice weevil) / 949 - 1080 (palm weevil)

### scaffold_34427

 * Set start of exon 1 to (-) 1305, removes some iffy bases from multiple alignment
 * Set end of exon 1 to (-)1089 for canonical splice site
 * Set start of exon 2 to (-)807 (splice site)

Produces a fragment of 90 amino acids, corresponding to positions 1131 - 1202 (rice weevil, with large gap) / 1137 - 1226 (palm weevil, no gap)

###  contig_80021

 * Set translation start (exon 1) to position 3
 * Set end of exon 1 to 239 (fixes splice site)
 * set start of exon 2 to 298 (fixes splice site)
 * Set end of exon 2 to position 420 (fixes splice site)
 * Set start of exon 3 to 485 (fixes splice site)
 * Set end of exon 3 to 679 (fixes splice site)
 * Set start of exon 4 to 737 (fixes splice site)
 * Set end of exon 4 to 878  (fixes splice site)
 * Set start of exon 5 to 964  (fixes splice site)
 * Set end of exon 5 to 1067 (fixes splice site)
 * Set start of exon 6 to 1129 (fixes splice site)
 * Set end of exon 6 to 1704 (fixes splice site)
 * Set start of exon 6 to 1955 (fixes splice site)
 
Produces a fragment of 570 amino acids, corresponds to positions 1313 - 1882 (rice weevil) / 1337 - 1906 (palm weevil)

### contig_195328

Single exon

 * No changes needed (end of protein)

Produces a fragment of 105 amino acids, corresponding to positions 1928 - 2044 (rice weevil) / 1952 - 2054 )palm weevil


GFF format annotations are copied below

```
##gff-version 3
##sequence-region contig_95372 1 798
contig_95372	.	gene	290	797	.	-	.	owner=nmiller11@iit.edu;ID=46d56908-57be-4705-ba5c-715f002e95ff;date_last_modified=2024-06-18;Name=contig_95372_2;date_creation=2024-06-18
contig_95372	.	mRNA	290	797	.	-	.	owner=nmiller11@iit.edu;Parent=46d56908-57be-4705-ba5c-715f002e95ff;ID=619fe606-a534-424c-85f1-4024cd413e8e;orig_id=contig_95372_2;date_last_modified=2024-06-18;Name=contig_95372_2-00001;date_creation=2024-06-18
contig_95372	.	exon	290	418	.	-	.	Parent=619fe606-a534-424c-85f1-4024cd413e8e;ID=9354c95b-be48-47a6-92b1-2c0dbb768312;Name=9354c95b-be48-47a6-92b1-2c0dbb768312
contig_95372	.	CDS	682	797	.	-	0	Parent=619fe606-a534-424c-85f1-4024cd413e8e;ID=619fe606-a534-424c-85f1-4024cd413e8e-CDS;Name=619fe606-a534-424c-85f1-4024cd413e8e-CDS
contig_95372	.	CDS	290	418	.	-	1	Parent=619fe606-a534-424c-85f1-4024cd413e8e;ID=619fe606-a534-424c-85f1-4024cd413e8e-CDS;Name=619fe606-a534-424c-85f1-4024cd413e8e-CDS
contig_95372	.	exon	682	797	.	-	.	Parent=619fe606-a534-424c-85f1-4024cd413e8e;ID=586a4cba-8e75-45cf-9819-5f2c645ba8e2;Name=586a4cba-8e75-45cf-9819-5f2c645ba8e2
###

##gff-version 3
##sequence-region scaffold_51779 1 1680
scaffold_51779	.	gene	1093	1680	.	-	.	owner=nmiller11@iit.edu;ID=8511b4a5-1358-42ec-9b43-c220345911f6;date_last_modified=2024-06-18;Name=scaffold_51779_2;date_creation=2024-06-18
scaffold_51779	.	mRNA	1093	1680	.	-	.	owner=nmiller11@iit.edu;Parent=8511b4a5-1358-42ec-9b43-c220345911f6;ID=2d28479f-9f46-4a4d-a25d-4eec5d636b9a;date_last_modified=2024-06-18;Name=scaffold_51779_2-00002;date_creation=2024-06-18
scaffold_51779	.	CDS	1511	1678	.	-	0	Parent=2d28479f-9f46-4a4d-a25d-4eec5d636b9a;ID=7e7a6200-4bd1-4ec5-960e-492350a119b1;Name=7e7a6200-4bd1-4ec5-960e-492350a119b1
scaffold_51779	.	CDS	1093	1215	.	-	0	Parent=2d28479f-9f46-4a4d-a25d-4eec5d636b9a;ID=7e7a6200-4bd1-4ec5-960e-492350a119b1;Name=7e7a6200-4bd1-4ec5-960e-492350a119b1
scaffold_51779	.	exon	1511	1680	.	-	.	Parent=2d28479f-9f46-4a4d-a25d-4eec5d636b9a;ID=2e88991f-34ca-4074-8fce-df2dd403b42d;Name=2e88991f-34ca-4074-8fce-df2dd403b42d
scaffold_51779	.	exon	1093	1215	.	-	.	Parent=2d28479f-9f46-4a4d-a25d-4eec5d636b9a;ID=9871da6a-2f47-4f50-980c-ca25f075de81;Name=9871da6a-2f47-4f50-980c-ca25f075de81
###



##gff-version 3
##sequence-region contig_245694 1 2999
contig_245694	.	gene	1515	1759	.	+	.	owner=nmiller11@iit.edu;ID=46b59481-f30d-4aad-b9ad-fb53b7eb96bb;date_last_modified=2024-06-18;Name=contig_245694_2;date_creation=2024-06-18
contig_245694	.	mRNA	1515	1759	.	+	.	owner=nmiller11@iit.edu;Parent=46b59481-f30d-4aad-b9ad-fb53b7eb96bb;ID=f0632a7f-5592-4dd4-b753-287182ea73ac;orig_id=contig_245694_2;date_last_modified=2024-06-18;Name=contig_245694_2-00001;date_creation=2024-06-18
contig_245694	.	CDS	1515	1759	.	+	0	Parent=f0632a7f-5592-4dd4-b753-287182ea73ac;ID=f0632a7f-5592-4dd4-b753-287182ea73ac-CDS;Name=f0632a7f-5592-4dd4-b753-287182ea73ac-CDS
contig_245694	.	exon	1515	1759	.	+	.	Parent=f0632a7f-5592-4dd4-b753-287182ea73ac;ID=4b0dd3f8-3ad3-402a-9123-b98d86044324;Name=4b0dd3f8-3ad3-402a-9123-b98d86044324
###



##gff-version 3
##sequence-region contig_322045 1 642
contig_322045	.	gene	146	611	.	-	.	owner=nmiller11@iit.edu;ID=e1e561fd-b7a5-465d-9f7a-496eec146067;date_last_modified=2024-06-18;Name=contig_322045_2;date_creation=2024-06-18
contig_322045	.	mRNA	146	611	.	-	.	owner=nmiller11@iit.edu;Parent=e1e561fd-b7a5-465d-9f7a-496eec146067;ID=b8bf4f15-21a8-4e53-803d-536a9f43867f;orig_id=contig_322045_2;date_last_modified=2024-06-18;Name=contig_322045_2-00001;date_creation=2024-06-18
contig_322045	.	exon	146	349	.	-	.	Parent=b8bf4f15-21a8-4e53-803d-536a9f43867f;ID=a9de6ba5-d336-4990-ad16-86acdcff021f;Name=a9de6ba5-d336-4990-ad16-86acdcff021f
contig_322045	.	exon	423	611	.	-	.	Parent=b8bf4f15-21a8-4e53-803d-536a9f43867f;ID=3112fda0-5e3a-4b39-9d12-9cb4605d1299;Name=3112fda0-5e3a-4b39-9d12-9cb4605d1299
contig_322045	.	CDS	423	611	.	-	0	Parent=b8bf4f15-21a8-4e53-803d-536a9f43867f;ID=b8bf4f15-21a8-4e53-803d-536a9f43867f-CDS;Name=b8bf4f15-21a8-4e53-803d-536a9f43867f-CDS
contig_322045	.	CDS	146	349	.	-	0	Parent=b8bf4f15-21a8-4e53-803d-536a9f43867f;ID=b8bf4f15-21a8-4e53-803d-536a9f43867f-CDS;Name=b8bf4f15-21a8-4e53-803d-536a9f43867f-CDS
###


##gff-version 3
##sequence-region contig_80021 1 2287
contig_80021	.	gene	3	2287	.	+	.	owner=nmiller11@iit.edu;ID=8b406196-6fc8-49a6-ad55-538693114ffb;date_last_modified=2024-06-25;Name=contig_80021_12;date_creation=2024-06-25
contig_80021	.	mRNA	3	2287	.	+	.	owner=nmiller11@iit.edu;Parent=8b406196-6fc8-49a6-ad55-538693114ffb;ID=c754f86d-b28c-4571-9b63-855db52e05bc;orig_id=contig_80021_12;date_last_modified=2024-06-26;Name=contig_80021_12-00001;date_creation=2024-06-25
contig_80021	.	exon	298	420	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=2d578d6b-e97b-4721-bd40-c35d82a67052;Name=2d578d6b-e97b-4721-bd40-c35d82a67052
contig_80021	.	exon	964	1067	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=098e3361-6114-46f3-b34e-b8290dcf171b;Name=098e3361-6114-46f3-b34e-b8290dcf171b
contig_80021	.	CDS	3	239	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	298	420	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	485	679	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	737	878	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	964	1067	.	+	2	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	1129	1704	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	CDS	1955	2287	.	+	0	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=c754f86d-b28c-4571-9b63-855db52e05bc-CDS;Name=c754f86d-b28c-4571-9b63-855db52e05bc-CDS
contig_80021	.	exon	1129	1704	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=91f23827-a47e-47c8-a776-99b10e3bd8e6;Name=91f23827-a47e-47c8-a776-99b10e3bd8e6
contig_80021	.	exon	485	679	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=70f83230-9e1b-4129-b198-28c073df989e;Name=70f83230-9e1b-4129-b198-28c073df989e
contig_80021	.	exon	1955	2287	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=06fb61d1-da15-439a-b31f-30d1e262d0ec;Name=06fb61d1-da15-439a-b31f-30d1e262d0ec
contig_80021	.	exon	3	239	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=d1eaf16c-4b11-48f8-8332-2d3813d77aa9;Name=d1eaf16c-4b11-48f8-8332-2d3813d77aa9
contig_80021	.	exon	737	878	.	+	.	Parent=c754f86d-b28c-4571-9b63-855db52e05bc;ID=b30c9b33-e457-46d5-97cc-edd23431c9ab;Name=b30c9b33-e457-46d5-97cc-edd23431c9ab
###


##gff-version 3
##sequence-region contig_195328 1 1006
contig_195328	.	gene	689	1006	.	-	.	owner=nmiller11@iit.edu;ID=e4a94ab9-d4e0-474c-bc47-d9908306dee6;date_last_modified=2024-06-26;Name=contig_195328_2;date_creation=2024-06-26
contig_195328	.	mRNA	689	1006	.	-	.	owner=nmiller11@iit.edu;Parent=e4a94ab9-d4e0-474c-bc47-d9908306dee6;ID=ae3bc4d9-f164-4cb4-868e-6fabef29f06b;orig_id=contig_195328_2;date_last_modified=2024-06-26;Name=contig_195328_2-00001;date_creation=2024-06-26
contig_195328	.	CDS	689	1006	.	-	0	Parent=ae3bc4d9-f164-4cb4-868e-6fabef29f06b;ID=ae3bc4d9-f164-4cb4-868e-6fabef29f06b-CDS;Name=ae3bc4d9-f164-4cb4-868e-6fabef29f06b-CDS
contig_195328	.	exon	689	1006	.	-	.	Parent=ae3bc4d9-f164-4cb4-868e-6fabef29f06b;ID=905be284-4d61-426f-aa48-559effe5f3d3;Name=905be284-4d61-426f-aa48-559effe5f3d3
###
```
