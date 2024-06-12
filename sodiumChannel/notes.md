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
