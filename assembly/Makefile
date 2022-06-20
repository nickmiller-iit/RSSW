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

# Use redundans to remove redundant contigs due to pooled input DNA
redundansOutDir=flyeRedundans

redundansOutput=$(redundansOutDir)/scaffolds.reduced.fa

redundansOpts=--threads 54 --mem 128 --outdir $(redundansOutDir)

$(redundansOutput): $(flyeOut)
	conda run --no-capture-output -n rssw-redundans redundans.py $(redundansOpts) -f $(flyeOut)

.PHONY: deduplicate

deduplicate: $(redundansOutput)

# Basic stats for assembly deduplicated with redundans

flyeRedundansAsmStatsFile=$(redundansOutDir)/assembly.stats

$(flyeRedundansAsmStatsFile): $(redundansOutput)
	conda run -n rssw-assemblyStats assembly-stats $(redundansOutput) > $(flyeRedundansAsmStatsFile)

.PHONY: flyeRedundansAsm-stats

flyeRedundansAsm-stats: $(flyeRedundansAsmStatsFile)


# BUSCO analysis of the flye assembly deduplicated with redundans

BUSCOFlyeRedundansOutDir=busco_flyeRedundans

BUSCOFlyeRedundansOutFile=$(BUSCOFlyeRedundansOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOFlyeRedundansOutFile): $(redundansOutput)
	conda run --no-capture-output -n rssw-busco busco -i $(redundansOutput) $(BUSCOOpts) --out $(BUSCOFlyeRedundansOutDir)

.PHONY: busco-analysis-flyeRedundans

busco-analysis-flyeRedundans: $(BUSCOFlyeRedundansOutFile) 

# As an alternative to redundans, try purge_dups.

purgeDupsOutDir=flyePurgeDups


$(purgeDupsOutDir):
	if [ ! -d $(purgeDupsOutDir) ]; then mkdir $(purgeDupsOutDir); fi

purgeDupsMappedReads=$(purgeDupsOutDir)/$(subst .fastq.gz,.paf.gz,$(notdir $(assemblyHifiReads)))

$(purgeDupsMappedReads): $(flyeOut) $(assemblyHifiReads) | $(purgeDupsOutDir)
	conda run --no-capture-output -n rssw-purge_dups minimap2 -x map-hifi -t 56 $(flyeOut) $(assemblyHifiReads) | gzip -c > $(purgeDupsMappedReads)

purgeDupsCovStats=$(purgeDupsOutDir)/PB.stat

$(purgeDupsCovStats): $(purgeDupsMappedReads)
	conda run --no-capture-output -n rssw-purge_dups pbcstat -O $(purgeDupsOutDir) $(purgeDupsMappedReads)

purgeDupsCutoffs=$(purgeDupsOutDir)/cutoffs

$(purgeDupsCutoffs): $(purgeDupsCovStats)
	conda run --no-capture-output -n rssw-purge_dups calcuts $(purgeDupsCovStats) > $(purgeDupsCutoffs)

purgeDupsSplitAssembly=$(purgeDupsOutDir)/$(notdir $(flyeOut)).split

$(purgeDupsSplitAssembly): $(flyeOut)
	conda run --no-capture-output -n rssw-purge_dups split_fa $(flyeOut) > $(purgeDupsSplitAssembly)

purgeDupsSelfAlignment=$(purgeDupsSplitAssembly).self.paf.gz

$(purgeDupsSelfAlignment): $(purgeDupsSplitAssembly)
	conda run --no-capture-output -n rssw-purge_dups minimap2 -x asm5 -t 56 $(purgeDupsSplitAssembly) $(purgeDupsSplitAssembly) | gzip -c > $(purgeDupsSelfAlignment)

purgeDupsBedOut=$(purgeDupsOutDir)/dups.bed

$(purgeDupsBedOut): $(purgeDupsSelfAlignment) $(purgeDupsCutoffs)
	conda run --no-capture-output -n rssw-purge_dups purge_dups -2 -T $(purgeDupsCutoffs) -c $(purgeDupsOutDir)/PB.base.cov $(purgeDupsSelfAlignment) > $(purgeDupsBedOut)

# The final step, get_seqs produces 2 fasta files: purged.fa and hap.fa. Annoyingly this always get put into the working dir
# so we will want to link them into the purge_dups output dir. 

purged.fa: $(purgeDupsBedOut) $(flyeOut)
	conda run --no-capture-output -n rssw-purge_dups get_seqs -e $(purgeDupsBedOut) $(flyeOut)

purgeDupsOutFiles=$(purgeDupsOutDir)/purged.fa $(purgeDupsOutDir)/hap.fa

$(purgeDupsOutFiles): purged.fa
	ln $(notdir $@) $@

.PHONY: deduplicate-purge_dups

deduplicate-purge_dups: $(purgeDupsOutFiles)

# get assembly stats for the purged assembly, also get the for the haplotigs while we are at it

flyePurgeDupsAsmStats=$(addsuffix .stats,$(purgeDupsOutFiles))

$(flyePurgeDupsAsmStats): $(purgeDupsOutFiles)
	conda run -n rssw-assemblyStats assembly-stats $(subst .stats,,$@) > $@

.PHONY: flyePurgeDupsAsm-stats

flyePurgeDupsAsm-stats: $(flyePurgeDupsAsmStats)

# run BUSCO on the purge_dups assembly, for comparison with others.


purgeDupsAsm=$(filter %purged.fa,$(purgeDupsOutFiles)) # just the purged assembly

BUSCOFlyePurgeDupsOutDir=busco_flyePurgeDups

BUSCOFlyePurgeDupsOutFile=$(BUSCOFlyePurgeDupsOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOFlyePurgeDupsOutFile): $(purgeDupsOutFiles)
	conda run --no-capture-output -n rssw-busco busco -i $(purgeDupsAsm) $(BUSCOOpts) --out $(BUSCOFlyePurgeDupsOutDir)

.PHONY: busco-analysis-flyePurgeDups

busco-analysis-flyePurgeDups: $(BUSCOFlyePurgeDupsOutFile)


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

