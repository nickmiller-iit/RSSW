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

asmStatsFile=$(flyeAsmDir)/assembly.stats

$(asmStatsFile): $(flyeOut)
	conda run -n rssw-assemblyStats assembly-stats $(flyeOut) > $(asmStatsFile)

.PHONY: asm-stats

asm-stats: $(asmStatsFile)

# BUSCO analysis of the initial assembly

BUSCOLineage=endopterygota_odb10

BUSCOOutDir=busco_flye

BUSCOOutFile=$(BUSCOOutDir)/$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOOutFile): $(flyeOut)
	conda run --no-capture-output -n rssw-busco busco -i $(flyeOut) $(BUSCOOpts) --out $(BUSCOOutDir)

.PHONY: busco-analysis

busco-analysis: $(BUSCOOutFile) 

# initial assembly with hifiasm

hifiasmPrefix=rssw_hifiasm

hifiasmOutFile=$(hifiasmPrefix).p_ctg.gfa

hifiasmOpts=-o $(hifiasmPrefix)  --primary -t 56

$(hifiasmOutFile): $(assemblyHifiReads)
	conda run --no-capture-output -n rssw-hifiasm hifiasm $(hifiasmOpts) $(assemblyHifiReads)

.PHONY: hifiasm-asm

hifiasm-asm: $(hifiasmOutFile)

.PHONY: test

test:
	echo $(hifiasmPrefix)
