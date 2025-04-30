# Our genome to annotate

genome=../assembly/RSSWDraftGenome.fasta


# Masking the genome

## We already ran RepeatModeler and RepeatMasker for pool-seq variant calling. However for gene modeling we want to run
## RepeatMasker with slightly different params - notably don't mak low complexity regions. Can re-use the repeats library produced
## prevously with RepeatModeler.

maskDir=masking

$(maskDir):
	if [ ! -d $(maskDir) ]; then mkdir $(maskDir); fi

repeatsLib=../repeats/RSSW-families.fa

## Repeatmasker produces several output files. We mostly want the softmasked (lower case) geome file

#masking/RSSWDraftGenome.fasta.masked

maskedGenome=$(maskDir)/$(notdir $(genome)).masked

$(maskedGenome): $(genome) $(repeatsLib) | $(maskDir)
	conda run --no-capture-output -n rssw-repeatmasker RepeatMasker  -lib $(repeatsLib) -dir $(maskDir) -par 28 -nolow -xsmall -gff $(genome)

.PHONY: mask

mask: $(maskedGenome)

# Mapping RNA-Seq data

rnaSeqDir=rnaSeq

$(rnaSeqDir):
	if [ ! -d $(rnaSeqDir) ]; then mkdir $(rnaSeqDir); fi

## index for hisat. Mutiple files are produced, use the first one as a trigger.

hisatPrefix=$(rnaSeqDir)/$(notdir $(maskedGenome))

hisatIndex=$(hisatPrefix).1.ht2

$(hisatIndex): $(maskedGenome) | $(rnaSeqDir)
	conda run --no-capture-output -n rssw-hisat2 hisat2-build $(maskedGenome) $(hisatPrefix)

rnaSeqLeft=../RNASeq/01.RawData/S2/S2_1.fq.gz

rnaSeqRight=../RNASeq/01.RawData/S2/S2_2.fq.gz

rnaSeqAlignments=$(rnaSeqDir)/alignedRNA.bam

$(rnaSeqAlignments): $(hisatIndex)
	conda run --no-capture-output -n rssw-hisat2 hisat2 -p 28 -x $(hisatPrefix) -1 $(rnaSeqLeft) -2 $(rnaSeqRight) | conda run --no-capture-output -n rssw-hisat2 samtools view -b > $(rnaSeqDir)/tmp.bam
	conda run --no-capture-output -n rssw-hisat2 samtools sort $(rnaSeqDir)/tmp.bam > $(rnaSeqAlignments)
	rm $(rnaSeqDir)/tmp.bam

rnaSeqAlignmentsIDX=$(rnaSeqAlignments).bai

$(rnaSeqAlignmentsIDX): $(rnaSeqAlignments)
	conda run --no-capture-output -n rssw-hisat2 samtools index $(rnaSeqAlignments)

.PHONY: align-rnaSeq

align-rnaSeq: $(rnaSeqAlignmentsIDX)



### braker.pl --GENEMARK_PATH=/home/nick/miniconda3/envs/rssw-braker2/bin/gmes_linux_64_4/ --species=smicronyxFulvus --softmasking -genome=../../assembly/RSSWDraftGenome.fasta --bam=../rnaSeq/alignedRNA.bam
### --workingdir=/path/to/wd/
### --AUGUSTUS_ab_initio

## Although we can install braker2 via conda, GeneMark and GenomeThreader have to be manuall installed into the conda env.
## We also have to install the GeneMark license file manually into $HOME


braker2Options=--GENEMARK_PATH=/home/nick/miniconda3/envs/rssw-braker2/bin/gmes_linux_64_4/ --species=Smicronyx_fulvus --softmasking --cores=28 --gff3 --prg=gth --gth2traingenes --AUGUSTUS_ab_initio

## use proteins from boll weevil to help train

bollWeevilProteins=other_species/GCF_022605725.1/protein.faa

## Braker produces lots of output files, use augustus.hints.aa, the predicted proteins as the target

brakerOut=braker/augustus.hints.aa

$(brakerOut): $(rnaSeqAlignmentsIDX) $(maskedGenome)
	conda run --no-capture-output -n rssw-braker2 braker.pl $(braker2Options) --genome=$(maskedGenome) --prot_seq=$(bollWeevilProteins) --bam=$(rnaSeqAlignments)


## Link the final annotation protein FASTA and annotation GFF to the top of the annotation dir
## Use the proteins as the trigger

annotationsFinal=braker.proteins.fasta

$(annotationsFinal): $(brakerOut)
	ln $(brakerOut) $(annotationsFinal)
	ln braker/Smicronyx_fulvus/augustus.hints.gff3 braker.genes.gff3

.PHONY: annotations

annotations: $(annotationsFinal)

# BUSCO analysis of predicted proteins


BUSCOLineage=endopterygota_odb10

BUSCOOutDir=busco

BUSCOOutFile=$(BUSCOOutDir)/run_$(BUSCOLineage)/full_table.tsv

#BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

BUSCOOpts= --cpu 28 --mode proteins --lineage $(BUSCOLineage)

$(BUSCOOutFile): $(brakerOut)
	conda run --no-capture-output -n rssw-busco busco -i $(brakerOut) $(BUSCOOpts) --out $(BUSCOOutDir)

.PHONY: busco

busco: $(BUSCOOutFile)

# Looking for Cytochrome P450s with interproscan
# Despite repeated apptempts, getting the conda version of interproscan to work was a non-starter.
# Instead use containerzied version with singularity.

interProContainer=interproscan_latest.sif

$(interProContainer):
	singularity pull docker://interpro/interproscan:latest

interProOutDir=interproscan.out

interProDataDir=interproscan-5.72-103.0/data

interProTmpDir=temp

interProInputDir=interproscan.in

$(interProOutDir):
	if [ ! -d $(interProOutDir) ]; then mkdir $(interProOutDir); fi

$(interProTmpDir):
	if [ ! -d $(interProTmpDir) ]; then mkdir $(interProTmpDir); fi


$(interProInputDir):
	if [ ! -d $(interProInputDir) ]; then mkdir $(interProInputDir); fi

# One of the default ouputs is tsv

interProOut=$(interProDir)/$(annotationsFinal).tsv

interProOpts=--input /input/tmp.fasta --output-dir /output --tempdir /temp  --goterms --cpu 12

singularityOpts=-B $(PWD)/$(interProDataDir):/opt/interproscan/data -B $(PWD)/$(interProInputDir):/input -B $(PWD)/$(interProTmpDir):/temp -B $(PWD)/$(interProOutDir):/output



#NB have to strip asterisks from input
$(interProOut): $(annotationsFinal) $(interProContainer) | $(interProOutDir) $(interProDataDir) $(interProTmpDir) $(interProInputDir)
	cat $(annotationsFinal)  | sed 's/\*//g' > $(interProInputDir)/tmp.fasta
	singularity exec $(singularityOpts) $(interProContainer) /opt/interproscan/interproscan.sh $(interProOpts)
	rm -r $(interProTmpDir) $(interProInputDir)

.PHONY: interpro

interpro: $(interProOut)
