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

# $(interProTmpDir):
# 	if [ ! -d $(interProTmpDir) ]; then mkdir $(interProTmpDir); fi


# $(interProInputDir):
# 	if [ ! -d $(interProInputDir) ]; then mkdir $(interProInputDir); fi

# One of the default ouputs is tsv

interProOut=$(interProOutDir)/$(annotationsFinal).tsv

interProOpts=--input /input/$(annotationsFinal) --output-dir /output --tempdir /temp  --goterms --cpu 12

singularityOpts=-B $(PWD)/$(interProDataDir):/opt/interproscan/data -B $(PWD)/$(interProInputDir):/input -B $(PWD)/$(interProTmpDir):/temp -B $(PWD)/$(interProOutDir):/output



#NB have to strip asterisks from input
$(interProOut): $(annotationsFinal) $(interProContainer) | $(interProOutDir) $(interProDataDir)
	if [ ! -d $(interProTmpDir) ]; then mkdir $(interProTmpDir); fi
	if [ ! -d $(interProInputDir) ]; then mkdir $(interProInputDir); fi
	cat $(annotationsFinal)  | sed 's/\*//g' > $(interProInputDir)/$(annotationsFinal)
	singularity exec $(singularityOpts) $(interProContainer) /opt/interproscan/interproscan.sh $(interProOpts)
	rm -r $(interProTmpDir) $(interProInputDir)

.PHONY: interpro

interpro: $(interProOut)

# Fishing out the likely cytochrome P450s

P450Dir=cytochromeP450

$(P450Dir):
	if [ ! -d $(P450Dir) ]; then mkdir $(P450Dir); fi

# get the list of P450s

P450List=$(P450Dir)/cytochromeP450.list

$(P450List): $(interProOut)  | $(P450Dir)
	grep [Pp]450 $(interProOut) | cut -f1 | sort -u > $(P450List)


# get the sequences of the P450s. While we are at it, remove the * for stop codon that braker puts in

P450Seqs=$(P450Dir)/cytochromeP450.fasta


$(P450Seqs): $(P450List) $(annotationsFinal)
	conda run --no-capture-output -n rssw-seqkit seqkit grep -f $(P450List) $(annotationsFinal) | sed 's/\*//g' > $(P450Seqs)

.PHONY: p450s

p450s: $(P450Seqs)

# A few sequences are from fused gene models, clean those up
# There are also 2 NADPH-cytochrome p450 reductases (jg41129.t1 and jg24569.t1) that need to be removed
P450SeqsEdited=$(P450Dir)/cytochromeP450_edited.fasta


$(P450SeqsEdited): $(P450Seqs)
	echo jg6524.t1 > $(P450Dir)/toedit.list
	echo jg12337.t1 >> $(P450Dir)/toedit.list
	echo jg32387.t1 >> $(P450Dir)/toedit.list
	grep -v -f $(P450Dir)/toedit.list  cytochromeP450/cytochromeP450.list | grep -v jg41129.t1 | grep -v jg24569.t1   > $(P450Dir)/noedit.list
	conda run --no-capture-output -n rssw-seqkit seqkit grep -f $(P450Dir)/noedit.list $(P450Seqs) > $(P450SeqsEdited)
	conda run --no-capture-output -n rssw-seqkit seqkit grep -p jg6524.t1 $(P450Seqs) | conda run --no-capture-output -n rssw-seqkit seqkit subseq -r 235:741 >> $(P450SeqsEdited)
	conda run --no-capture-output -n rssw-seqkit seqkit grep -p jg12337.t1 $(P450Seqs) | conda run --no-capture-output -n rssw-seqkit seqkit subseq -r 389:804  >> $(P450SeqsEdited)
	conda run --no-capture-output -n rssw-seqkit seqkit grep -p jg32387.t1 $(P450Seqs) | conda run --no-capture-output -n rssw-seqkit seqkit subseq -r 372:815 >> $(P450SeqsEdited)
	rm $(P450Dir)/toedit.list $(P450Dir)/noedit.list


.PHONY: p450s-edited

p450s-edited: $(P450SeqsEdited)


# Align the CYPs that are >- 350 aas in length, i.e. near full length

## List of full lenngth CYPs comes from R markdown document

p450sLongList=$(P450Dir)/cytochromeP450_long.list

p450sLongSeqs=$(P450Dir)/cytochromeP450_long.fasta

$(p450sLongSeqs): $(P450SeqsEdited) $(p450sLongList)
	conda run --no-capture-output -n rssw-seqkit seqkit grep -f $(p450sLongList) $(P450SeqsEdited) > $(p450sLongSeqs)

## align the full length CYPS with muscle

p450sLongSeqsAligned=$(P450Dir)/cytochromeP450_long_aligned.fasta

$(p450sLongSeqsAligned): $(p450sLongSeqs)
	conda run --no-capture-output -n rssw-muscle muscle -in $(p450sLongSeqs) -fastaout $(p450sLongSeqsAligned) -htmlout $(subst fasta,html,$@) -clwout $(subst fasta,clus,$@)


.PHONY: p450-align


p450-align: $(p450sLongSeqsAligned)
