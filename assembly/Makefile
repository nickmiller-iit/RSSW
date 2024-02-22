# Assemble red sunflower seed weevil genome from PacBio Hifi reads.


# Input read data

readDir=reads
allHifiReadFiles=$(readDir)/weevil_2_m64108e_211111_063517.hifi_reads.fastq.gz $(readDir)/weevil_m64108e_211030_220410.hifi_reads.fastq.gz $(readDir)/Weevil_m64108e_220407_204305.hifi_reads.fastq.gz

# Run fastqc to check read data

fastqcDir=fastqc_out

$(fastqcDir):
	if [ ! -d $(fastqcDir) ]; then mkdir $(fastqcDir); fi

fastqcFiles=$(subst .fastq.gz,_fastqc.html,$(subst $(readDir)/,$(fastqcDir)/,$(allHifiReadFiles)) )

fastqcOpts= -o $(fastqcDir) -t 16

$(fastqcFiles): $(allHifiReadFiles) | $(fastqcDir)
	conda run -n rssw-fastqc fastqc $(fastqcOpts) $(allHifiReadFiles)

.PHONY: fastqc

fastqc: $(fastqcFiles)

# Initial assembly with flye

#only use reads from good library
assemblyHifiReads=$(readDir)/Weevil_m64108e_220407_204305.hifi_reads.fastq.gz

flyeAsmDir=flyeAssembly

flyeOpts=--threads 56

#main output of fly assembly
flyeOut=$(flyeAsmDir)/assembly.fasta

$(flyeOut): $(assemblyHifiReads)
	conda run -n rssw-flye flye --pacbio-hifi $(assemblyHifiReads) $(flyeOpts) --out-dir $(flyeAsmDir)

.PHONY: flye-asm

flye-asm: $(flyeOut)

# Basic stats for initial assembly

flyeAsmStatsFile=$(flyeAsmDir)/assembly.stats

$(flyeAsmStatsFile): $(flyeOut)
	conda run -n rssw-assemblyStats assembly-stats $(flyeOut) > $(flyeAsmStatsFile)

.PHONY: flyeAsm-stats

flyeAsm-stats: $(flyeAsmStatsFile)

# BUSCO analysis of the initial assembly

BUSCOLineage=endopterygota_odb10

BUSCOFlyeOutDir=busco_flye

BUSCOFlyeOutFile=$(BUSCOFlyeOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOFlyeOutFile): $(flyeOut)
	conda run --no-capture-output -n rssw-busco busco -i $(flyeOut) $(BUSCOOpts) --out $(BUSCOFlyeOutDir)

.PHONY: busco-analysis-flye

busco-analysis-flye: $(BUSCOFlyeOutFile) 

# Decontaminate the initial flye assembly using information from blobtools.

flyeDeconDir=flyeDecon

$(flyeDeconDir):
	if [ ! -d $(flyeDeconDir) ]; then mkdir $(flyeDeconDir); fi

blobTable=../blobtools/flyeAssembly/superkingdom.assembly.fasta.blobDB.table.txt

deconContigs=$(flyeDeconDir)/contigs.list

$(deconContigs): $(blobTable) | $(flyeDeconDir)
	grep "Eukaryota" $(blobTable) > $(flyeDeconDir)/tmp
	grep "no-hit" $(blobTable) >> $(flyeDeconDir)/tmp
	cut -f1 $(flyeDeconDir)/tmp > $(deconContigs)
	rm $(flyeDeconDir)/tmp

.PHONY: decon-contigs

decon-contigs: $(deconContigs)

##use samtools faidx to extract non-contaminant contigs

flyeOutIdx=$(flyeOut).fai

$(flyeOutIdx): $(flyeOut)
	conda run --no-capture-output -n rssw-samtools samtools faidx $(flyeOut)

deconOut=$(flyeDeconDir)/assemblyDecon.fasta

$(deconOut): $(flyeOut) $(flyeOutIdx) $(deconContigs)
	for ctg in `cat $(deconContigs)`; do \
		conda run --no-capture-output -n rssw-samtools samtools faidx $(flyeOut) $$ctg >> $(deconOut); \
	done

.PHONY: decon

decon: $(deconOut)

## Assembly stats for decontamianted assembly

flyeDeconStatsFile=$(flyeDeconDir)/assembly.stats

$(flyeDeconStatsFile): $(deconOut)
	conda run -n rssw-assemblyStats assembly-stats $(deconOut) > $(flyeDeconStatsFile)

.PHONY: flyedecon-stats

flyedecon-stats: $(flyeDeconStatsFile)

## BUSCO analysis for decontaminated assembly

BUSCOFlyeDeconOutDir=busco_flyeDecon

BUSCOFlyeDeconOutFile=$(BUSCOFlyeDeconOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOFlyeDeconOutFile): $(deconOut)
	conda run --no-capture-output -n rssw-busco busco -i $(deconOut) $(BUSCOOpts) --out $(BUSCOFlyeDeconOutDir)

.PHONY: busco-analysis-flyedecon

busco-analysis-flyedecon: $(BUSCOFlyeDeconOutFile) 

# Use redundans to remove redundant contigs from decontamiated flye assembly due to pooled input DNA

redundansOutDir=flyeRedundansNoReads

redundansOutput=$(redundansOutDir)/scaffolds.reduced.fa

#redundansOpts=--threads 54 --mem 128 --longreads $(assemblyHifiReads) --outdir $(redundansOutDir)
redundansOpts=--threads 54 --mem 128  --outdir $(redundansOutDir)


$(redundansOutput): $(deconOut)
	conda run --no-capture-output -n rssw-redundans redundans.py $(redundansOpts) -f $(deconOut)

.PHONY: deduplicate

deduplicate: $(redundansOutput)

# Basic stats for assembly deduplicated with redundans

flyeRedundansAsmStatsFile=$(redundansOutDir)/assembly.stats

$(flyeRedundansAsmStatsFile): $(redundansOutput)
	conda run -n rssw-assemblyStats assembly-stats $(redundansOutput) > $(flyeRedundansAsmStatsFile)

.PHONY: flyeRedundansAsm-stats

flyeRedundansAsm-stats: $(flyeRedundansAsmStatsFile)


# BUSCO analysis of the flye assembly deduplicated with redundans

BUSCOFlyeRedundansOutDir=busco_flyeRedundansNoReads

BUSCOFlyeRedundansOutFile=$(BUSCOFlyeRedundansOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOFlyeRedundansOutFile): $(redundansOutput)
	conda run --no-capture-output -n rssw-busco busco -i $(redundansOutput) $(BUSCOOpts) --out $(BUSCOFlyeRedundansOutDir)

.PHONY: busco-analysis-flyeRedundans

busco-analysis-flyeRedundans: $(BUSCOFlyeRedundansOutFile) 

# Polishing the assembly with short reads


## Polishing with pilon.



polishDir=polish

$(polishDir):
	if [ ! -d $(polishDir) ]; then mkdir $(polishDir); fi


polishInputGenome=$(redundansOutput)

polishMappedReads=$(polishDir)/reads.bam

polishLeftReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz
polishRightReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz

$(polishMappedReads): $(polishLeftReads) $(polishRightReads) $(polishInputGenome) | $(polishDir)
	conda run --no-capture-output -n rssw-minimap2-samtools minimap2 -t 16 -ax sr $(polishInputGenome) $(polishLeftReads) $(polishRightReads) | conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b > $(polishDir)/tmp.bam
	conda run --no-capture-output -n rssw-minimap2-samtools samtools sort -@ 16 $(polishDir)/tmp.bam > $(polishMappedReads)
	rm $(polishDir)/tmp.bam

polishMappedReadsIDX=$(polishMappedReads).bai

$(polishMappedReadsIDX): $(polishMappedReads)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $(polishMappedReads)


### Pilon is a java program and a bit of a memory hog. If it runs out of memory because there are too many contigs it
### fails
### As a workaround, increase the memory for the java VM to 200 GB and split the polishing into batches of 500 contigs

polishContigIDs=$(polishDir)/contigIDs

$(polishContigIDs): $(polishInputGenome) | $(polishDir)
	grep ">" $(polishInputGenome) | tr -d ">" > $(polishContigIDs)

### Use the first file in the split as the the target

polishBatch0=$(polishDir)/batch_000

$(polishBatch0): $(polishContigIDs)
	split -a 3 -d -l 500 $(polishContigIDs) $(polishDir)/batch_

### Get the full set of batches to work through

polishBatches=$(shell ls $(polishDir)/batch_*)
#polishBatches=$(polishDir)/batch_000 $(polishDir)/batch_001

polishedContigs=$(addsuffix .fasta,$(polishBatches))


### Polishing each batch
### 1. Extract the contigs in the batch to a temporary file
### 2. Extract the reads aligned to the contigs in the batch to a temporary BAM file - NB we are already sorted
### 3  Index the temp BAM file
### 4. Use pilon to polish the contigs and output
### 5. Clean up tmp files

### Side note pilon has the annoying behaviour the --output specifys a "prefix" for the output files and appends .fasta


$(polishedContigs): $(polishBatch0)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools faidx -r $(basename $@) $(polishInputGenome) > $(subst .fasta,.tmp.fasta,$@)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools faidx $(subst .fasta,.tmp.fasta,$@)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b $(polishMappedReads) $(shell cat $(basename $@) | tr "\n" " ") > $(subst .fasta,.tmp.bam,$@)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $(subst .fasta,.tmp.bam,$@)
	conda run --no-capture-output -n rssw-pilon pilon -Xmx200G --genome $(subst .fasta,.tmp.fasta,$@)  --frags $(subst .fasta,.tmp.bam,$@)  --fix indels,snps --output $(basename $@)
	rm $(subst .fasta,.tmp.fasta,$@) $(addsuffix .fai,$(subst .fasta,.tmp.fasta,$@)) $(subst .fasta,.tmp.bam,$@) $(addsuffix .bai,$(subst .fasta,.tmp.bam,$@))

polishedAssembly=$(polishDir)/polishedGenome.fasta

.PHONY: polish-genome

polish-genome:
	cat $(shell ls $(polishDir)/batch_*.fasta) > $(polishedAssembly)







# BUSCO analysis of the polished assembly 

BUSCOPolishedOutDir=busco_polished

BUSCOPolishedOutFile=$(BUSCOPolishedOutDir)/run_$(BUSCOLineage)/full_table.tsv


$(BUSCOPolishedOutFile): $(redundansOutput)
	conda run --no-capture-output -n rssw-busco busco -i $(polishedAssembly) $(BUSCOOpts) --out $(BUSCOPolishedOutDir)


.PHONY: busco-analysis-polished

busco-analysis-polished: $(BUSCOPolishedOutFile)


# Attempting to scaffold using RNA-Seq data and rascaf
#
# Although pilon polishing did not have a major impact, it didn't seem to do any harm, so will start from there

rascafDir=rascaf_scaffolding

rascafInputGenome=$(polishedAssembly)

$(rascafDir):
	if [ ! -d $(rascafDir) ]; then mkdir $(rascafDir); fi

rnaSeqLeft=../RNASeq/01.RawData/S2/S2_1.fq.gz

rnaSeqRight=../RNASeq/01.RawData/S2/S2_2.fq.gz

### Map RNA-Seq data with Hisat 2
### Note that Hisat2 creates multiple index files named *.n.ht2, where n is a digit
### use the first file as a trigger for make

hisatPrefix=$(rascafDir)/preScaffolding

hisatIndex=$(hisatPrefix).1.ht2

$(hisatIndex): $(rascafInputGenome) | $(rascafDir)
	conda run --no-capture-output -n rssw-hisat2 hisat2-build $(rascafInputGenome) $(hisatPrefix)


rnaSeqAlignments=$(rascafDir)/alignedRNA.bam

$(rnaSeqAlignments): $(hisatIndex) $(rascafInputGenome)
	conda run --no-capture-output -n rssw-hisat2 hisat2 -p 28 -x $(hisatPrefix) -1 $(rnaSeqLeft) -2 $(rnaSeqRight) | conda run --no-capture-output -n rssw-hisat2 samtools view -b > $(rascafDir)/tmp.bam
	conda run --no-capture-output -n rssw-hisat2 samtools sort $(rascafDir)/tmp.bam > $(rnaSeqAlignments)
	rm $(rascafDir)/tmp.bam

rnaSeqAlignmentsIDX=$(rnaSeqAlignments).bai

$(rnaSeqAlignmentsIDX): $(rnaSeqAlignments)
	conda run --no-capture-output -n rssw-hisat2 samtools index $(rnaSeqAlignments)

rascafPrefix=$(rascafDir)/rascaf

rascafConnections=$(rascafPrefix).out

$(rascafConnections): $(rnaSeqAlignmentsIDX)
	conda run --no-capture-output -n rssw-rascaf rascaf -b $(rnaSeqAlignments) -f $(rascafInputGenome) -o $(rascafPrefix)

rascafScaffoldPrefix=$(rascafDir)/rascaf_scaffold


rascafScaffold=$(rascafScaffoldPrefix).fa

$(rascafScaffold): $(rascafConnections)
	conda run --no-capture-output -n rssw-rascaf rascaf-join -r $(rascafConnections) -o $(rascafScaffoldPrefix)


.PHONY scaffold:

scaffold: $(rascafScaffold)

### Run BUSCO analysis on the scaffolded assembly

BUSCOScaffoldedOutDir=busco_scaffolded

BUSCOScaffoldedOutFile=$(BUSCOScaffoldedOutDir)/run_$(BUSCOLineage)/full_table.tsv


$(BUSCOScaffoldedOutFile): $(rascafScaffold)
	conda run --no-capture-output -n rssw-busco busco -i $(rascafScaffold) $(BUSCOOpts) --out $(BUSCOScaffoldedOutDir)


.PHONY: busco-analysis-scaffolded

busco-analysis-scaffolded: $(BUSCOScaffoldedOutFile)


# The final assembly

## Having deduplicated, polished and scaffolded, there is not much more to do. Link the final final asembly to
## A file in the top level assembly dir so that we can find it easily and unambigously for downstream analysis.


finalAssembly=RSSWDraftGenome.fasta

$(finalAssembly): $(rascafScaffold)
	ln $(rascafScaffold) $(finalAssembly)

.PHONY: final

final: $(finalAssembly)
