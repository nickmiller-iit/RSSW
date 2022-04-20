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
