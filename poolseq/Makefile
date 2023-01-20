# Read trimming and QC

## The raw data

readsDir=data

rawReadsDir=$(readsDir)/raw

B1Raw=$(rawReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz
B2Raw=$(rawReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz
D1Raw=$(rawReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz
D2Raw=$(rawReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz
H1Raw=$(rawReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_1.fq.gz
H2Raw=$(rawReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_2.fq.gz
K1Raw=$(rawReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_1.fq.gz
K2Raw=$(rawReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_2.fq.gz
L1Raw=$(rawReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_1.fq.gz
L2Raw=$(rawReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_2.fq.gz
O1Raw=$(rawReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_1.fq.gz
O2Raw=$(rawReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_2.fq.gz
#O1RawExtra=$(rawReadsDir)/O_CKDN220061314-1A_HMMYMDSX5_L2_1.fq.gz
#O2RawExtra=$(rawReadsDir)/O_CKDN220061314-1A_HMMYMDSX5_L2_2.fq.gz
S1Raw=$(rawReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_1.fq.gz
S2Raw=$(rawReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_2.fq.gz
T1Raw=$(rawReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_1.fq.gz
T2Raw=$(rawReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_2.fq.gz

BRaw=$(B1Raw) $(B2Raw)
DRaw=$(D1Raw) $(D2Raw)
HRaw=$(H1Raw) $(H2Raw)
KRaw=$(K1Raw) $(K2Raw)
LRaw=$(L1Raw) $(L2Raw)
ORaw=$(O1Raw) $(O2Raw)
#ORawExtra=$(O1RawExtra) $(O2RawExtra)
SRaw=$(S1Raw) $(S2Raw)
TRaw=$(T1Raw) $(T2Raw)

#allRawReads=$(BRaw) $(DRaw) $(HRaw) $(KRaw) $(LRaw) $(ORaw) $(ORawExtra) $(SRaw) $(TRaw)
allRawReads=$(BRaw) $(DRaw) $(HRaw) $(KRaw) $(LRaw) $(ORaw) $(SRaw) $(TRaw)

## QC the raw data

rawQCDir=$(rawReadsDir)/QC

$(rawQCDir):
	if [ ! -d $(rawQCDir) ]; then mkdir $(rawQCDir); fi

rawQCFiles=$(subst fq.gz,_fastqc.html,$(subst $(rawReadsDir)/,$(rawQCDir)/,$(allRawReads)))

fastQCOpts= -t 16

$(rawQCFiles): $(allRawReads) | $(rawQCDir)
	conda run --no-capture-output -n rssw-fastqc fastqc $(fastQCOpts) -o $(rawQCDir) $(subst _fastqc.html,fq.gz,$(subst $(rawQCDir)/,$(rawReadsDir)/,$@))

.PHONY: qcRaw

qcRaw: $(rawQCFiles)

## Trim/clip the raw reads

trimmedReadsDir=$(readsDir)/trimmed

$(trimmedReadsDir):
	if [ ! -d $(trimmedReadsDir) ]; then mkdir $(trimmedReadsDir); fi



B1Trimmed=$(trimmedReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz
B2Trimmed=$(trimmedReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz
D1Trimmed=$(trimmedReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz
D2Trimmed=$(trimmedReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz
H1Trimmed=$(trimmedReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_1.fq.gz
H2Trimmed=$(trimmedReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_2.fq.gz
K1Trimmed=$(trimmedReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_1.fq.gz
K2Trimmed=$(trimmedReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_2.fq.gz
L1Trimmed=$(trimmedReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_1.fq.gz
L2Trimmed=$(trimmedReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_2.fq.gz
O1Trimmed=$(trimmedReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_1.fq.gz
O2Trimmed=$(trimmedReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_2.fq.gz
S1Trimmed=$(trimmedReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_1.fq.gz
S2Trimmed=$(trimmedReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_2.fq.gz
T1Trimmed=$(trimmedReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_1.fq.gz
T2Trimmed=$(trimmedReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_2.fq.gz

# Use the read 1 files as the targets to make. We are unlikely to want to make trimmed read 1 without also making trimmed read 2

trimmedRead1=$(B1Trimmed) $(D1Trimmed) $(H1Trimmed) $(K1Trimmed) $(L1Trimmed) $(O1Trimmed) $(S1Trimmed) $(T1Trimmed)
trimmedRead2=$(B2Trimmed) $(D2Trimmed) $(H2Trimmed) $(K2Trimmed) $(L2Trimmed) $(O2Trimmed) $(S2Trimmed) $(T2Trimmed)

allTrimmedReads=$(trimmedRead1) $(trimmedRead2)

fastpOpts= -3 -5 -l 30



$(trimmedRead1): $(allRawReads) | $(trimmedReadsDir)
	conda run --no-capture-output -n rssw-fastp fastp $(fastpOpts) --in1 $(subst $(trimmedReadsDir),$(rawReadsDir),$@)  --out1 $@ --in2 $(subst _1.fq,_2.fq,$(subst $(trimmedReadsDir),$(rawReadsDir),$@))  --out2 $(subst _1.fq,_2.fq,$@)

.PHONY: trim

trim: $(trimmedRead1)


trimmedQCDir=$(trimmedReadsDir)/QC

$(trimmedQCDir):
	if [ ! -d $(trimmedQCDir) ]; then mkdir $(trimmedQCDir); fi

trimmedQCFiles=$(subst fq.gz,_fastqc.html,$(subst $(trimmedReadsDir)/,$(trimmedQCDir)/,$(allTrimmedReads)))

fastQCOpts= -t 16

$(trimmedQCFiles): $(allTrimmedReads) | $(trimmedQCDir)
	conda run --no-capture-output -n rssw-fastqc fastqc $(fastQCOpts) -o $(trimmedQCDir) $(subst _fastqc.html,fq.gz,$(subst $(trimmedQCDir)/,$(trimmedReadsDir)/,$@))

.PHONY: qcTrimmed

qcTrimmed: $(trimmedQCFiles)

# Read alignment

alignDir=alignments

$(alignDir):
	if [ ! -d $(alignDir) ]; then mkdir $(alignDir); fi


## Use the same assembly that we used for repeat masking

genomeRef=../assembly/flyeRedundansNoReads/scaffolds.reduced.fa

alignments=$(addprefix $(alignDir)/,B.bam D.bam H.bam K.bam L.bam O.bam S.bam T.bam)

## Alignment step does several things
## 1. Align with minimap (sam output)
## 2. Run samtools fixmates on initial alignment
## 3. Sort by coordinate and output to temporary bam file
## 4. Mark and remove PCR duplicates
## 5. Remove temporary bam file
minimapOpts= -t 6

$(alignments): $(genomeRef) $(trimmedRead1) | $(alignDir)
	conda run --no-capture-output -n rssw-minimap2-samtools minimap2 $(minimapOpts) -ax sr $(genomeRef) $(trimmedReadsDir)/$(filter $(basename $(notdir $@))%,$(notdir $(trimmedRead1)))  $(trimmedReadsDir)/$(filter $(basename $(notdir $@))%,$(notdir $(trimmedRead2))) | conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b - | conda run --no-capture-output -n rssw-minimap2-samtools samtools fixmate -m -O bam - - | conda run --no-capture-output -n rssw-minimap2-samtools samtools sort  > $@.tmp; conda run --no-capture-output -n rssw-minimap2-samtools samtools markdup -r $@.tmp $@; rm $@.tmp

## Index the bam files for

alignmentIndexes=$(addsuffix .bai,$(alignments))

$(alignmentIndexes): $(alignments)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $(subst .bai,,$@)

.PHONY: align

align: $(alignmentIndexes)

## Before calling SNPs, clean up the bam files to remove:
## 1. Reads with low (<= 20) mapping qualities
## 2. Improperly paired reads (-f 0x2)
## 3. Reads in known repeats.

## Use bedtools to get the regions that are *not* identified by repeatmasker

repeatsGFF=../repeats/maskedNoScaff/scaffolds.reduced.fa.out.gff

nonRepeatsBED=$(alignDir)/noRepeats.bed

### We can make a genome file for bedtools from the first 2 cols of a fai index produced by samtools

genomeRefIndex=$(genomeRef).fai

bedGenome=$(alignDir)/genomeBed

$(bedGenome): $(genomeRefIndex)
	cut -f1,2 $(genomeRefIndex)  > $(bedGenome)

## Need to have BED file of repeats sorted in the same order as the chroms in the genome file
## easiest way to do this is with the faidx option.

repeatsBed=$(alignDir)/repeats.bed

$(repeatsBed): $(repeatsGFF)
	conda run --no-capture-output -n rssw-bedtools bedtools sort -faidx $(genomeRefIndex)  -i $(repeatsGFF) > $(repeatsBed)

$(nonRepeatsBED): $(bedGenome) $(repeatsBed)
	conda run --no-capture-output -n rssw-bedtools bedtools complement -i $(repeatsBed) -g $(bedGenome) > $(nonRepeatsBED)


## Filter out unwanted reads, write to clean.*.bam
## Also include sample info in read groups, so we know who's who
cleanAlignments=$(subst $(alignDir)/,$(alignDir)/clean.,$(alignments))

$(cleanAlignments): $(alignments) $(nonRepeatsBED)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools addreplacerg  -r "ID:$(notdir $@)" -r "SM:$(subst clean.,Site,$(basename $(notdir $@)))" $(subst clean.,,$@) | conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b -q 20 -f 0x2 -L $(nonRepeatsBED)  > $@

## index cleaned BAM files

cleanAlignmentIndexes=$(addsuffix .bai,$(cleanAlignments))

$(cleanAlignmentIndexes): $(cleanAlignments)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $(subst .bai,,$@)

.PHONY: clean-align

clean-align: $(cleanAlignmentIndexes)



# Variant calling


## Most variant callers start with a samtools pileup/mpileup file.

variantDir=variantCalling

$(variantDir):
	if [ ! -d $(variantDir) ]; then mkdir $(variantDir); fi

mpileupFile=$(variantDir)/mpileup.out.gz

$(mpileupFile): $(cleanAlignments) $(genomeRef) | $(variantDir)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools mpileup -f $(genomeRef) $(cleanAlignments) | gzip -c > $(mpileupFile)

.PHONY: mpileup

mpileup: $(mpileupFile)


## Variant calling with MAPGD
## MAPGD is not available in conda. Had to build it by hand (requires GSL).

MAPGDBIN=MAPGD/bin/mapgd

## Dir to place the output

MAPGDDir=$(variantDir)/MAPGD

$(MAPGDDir):
	if [ ! -d $(MAPGDDir) ]; then mkdir $(MAPGDDir); fi

## MAPGD requires a header from samtools to process the mpileup

MAPGDHeader=$(MAPGDDir)/mapgd.header

$(MAPGDHeader): $(cleanAlignments) | $(MAPGDDir)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools view -H $(filter %B.bam,$(cleanAlignments)) > $(MAPGDHeader)

## Next step is to reformat from mpileup to MAPGD .pro format
## Pro file gets pretty huge, so compress it.

MAPGDProFile=$(MAPGDDir)/allpops.pro.gz

## Samples names can be handed to mapgd proview as a comma separated list.
## Getting a comma separated list from a makefile variable is surprisingly tricky.
## Stack overflow to the rescue:
## https://stackoverflow.com/questions/7525589/create-comma-separated-lists-in-gnu-make
## Hopefully the order of the samples has not changed with mpileup

null  :=
space := $(null) #
comma := ,

## But apparenlty I'm not understanding what MAPGD wants

MAPGDSampleNames := $(subst $(space),$(comma),$(basename $(notdir $(alignments))))

$(MAPGDProFile): $(mpileupFile) $(MAPGDHeader)
	$(MAPGDBIN) proview -i $(mpileupFile) -H $(MAPGDHeader) | gzip -c > $(MAPGDProFile)
#	$(MAPGDBIN) proview -i $(mpileupFile) -H $(MAPGDHeader) -l $(MAPGDSampleNames) | gzip -c > $(MAPGDProFile)


## MAPGD pool command estimates allele frequencies for pooled dats
## -a flag controls log likelihood to accept as polymorphic

MAPGDOutFile=$(MAPGDDir)/allpops.mapgd.out.22.gz

$(MAPGDOutFile): $(MAPGDProFile)
	zcat $(MAPGDProFile) | $(MAPGDBIN) pool -a 22 | gzip -c > $(MAPGDOutFile)

.PHONY: mapgd

mapgd: $(MAPGDOutFile)

