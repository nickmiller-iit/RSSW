# Align Pool-seq reads to the short read assembly. Only keep this that align to a contig of scaffold
# containing part of the sodium channel gene

srGenome=../../assembly-shortreads/shortReadAssemblyScaffolded.fasta

# read fastqfiles

trimmedReadsDir=../../poolseq/data/trimmed

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

trimmedRead1=$(B1Trimmed) $(D1Trimmed) $(H1Trimmed) $(K1Trimmed) $(L1Trimmed) $(O1Trimmed) $(S1Trimmed) $(T1Trimmed)
trimmedRead2=$(B2Trimmed) $(D2Trimmed) $(H2Trimmed) $(K2Trimmed) $(L2Trimmed) $(O2Trimmed) $(S2Trimmed) $(T2Trimmed)

allTrimmedReads=$(trimmedRead1) $(trimmedRead2)


targetContigs=contig_95372 contig_245694 contig_322045 scaffold_34427 contig_80021  contig_195328

#Read alignment

alignDir=alignments

$(alignDir):
	if [ ! -d $(alignDir) ]; then mkdir $(alignDir); fi

minimapOpts= -t 6

alignments=$(addprefix $(alignDir)/,B.bam D.bam H.bam K.bam L.bam O.bam S.bam T.bam)

$(alignments): $(srGenome) $(allTrimmedReads) | $(alignDir)
	conda run --no-capture-output -n rssw-minimap2-samtools minimap2 $(minimapOpts) -ax sr $(srGenome) $(trimmedReadsDir)/$(filter $(basename $(notdir $@))%,$(notdir $(trimmedRead1)))  $(trimmedReadsDir)/$(filter $(basename $(notdir $@))%,$(notdir $(trimmedRead2))) | conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b - | conda run --no-capture-output -n rssw-minimap2-samtools samtools sort  > $@.tmp1
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $@.tmp1
	conda run --no-capture-output -n rssw-minimap2-samtools samtools view -b $@.tmp1 $(targetContigs)  > $@.tmp2
	conda run --no-capture-output -n rssw-minimap2-samtools samtools sort -n $@.tmp2 > $@.tmp3
	conda run --no-capture-output -n rssw-minimap2-samtools samtools fixmate -m -O bam $@.tmp3 - | conda run --no-capture-output -n rssw-minimap2-samtools samtools sort  > $@.tmp4 
	conda run --no-capture-output -n rssw-minimap2-samtools samtools markdup -r $@.tmp4 $@
	conda run --no-capture-output -n rssw-minimap2-samtools samtools index $@
	rm $@.tmp*

.PHONY: align

align: $(alignments)

variantDir=variantCalling

$(variantDir):
	if [ ! -d $(variantDir) ]; then mkdir $(variantDir); fi

#first use a merged data set with all samplest detect all polymorphic sites/

#samtools mpileup takes a file with the list of locations. Create that here

pileupTargetsFile=$(variantDir)/targets.txt

$(pileupTargetsFile): | $(variantDir)
	grep $(addprefix -e ',$(addsuffix \s',$(targetContigs))) $(srGenome).fai | cut -f1,2 | sed 's/\t/\t1\t/' > $(pileupTargetsFile)

combinedPileupFile=$(variantDir)/combinedPileup.out.gz

$(combinedPileupFile): $(alignments) $(srGenome) $(pileupTargetsFile)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools merge -o - $(alignments) | conda run --no-capture-output -n rssw-minimap2-samtools samtools mpileup -f $(srGenome) -l $(pileupTargetsFile)  - | gzip -c > $(combinedPileupFile)

.PHONY: pileup-combined

pileup-combined: $(combinedPileupFile)

## No conda or other easy installation options for SNAPE, have to build from source (needs OCAML compiler)

SNAPEBin=../../poolseq/snape-pooled/snape-pooled

SNAPEDir=$(variantDir)/SNAPE

$(SNAPEDir):
	if [ ! -d $(SNAPEDir) ]; then mkdir $(SNAPEDir); fi



# Although SNAPE is quite slow, we are only doing a handful of contigs so no need for all the gymnastics that we used when calling the entire genome

snapeCombinedOut=$(SNAPEDir)/combined.out

# Note run SNAPE and filter for calls with posterior prob >= 0.99 in one go
$(snapeCombinedOut): $(combinedPileupFile) | $(SNAPEDir)
	zcat $(combinedPileupFile) | $(SNAPEBin) -nchr 480 -fold folded -priortype flat -noextremes | awk '{if ( 1 - ( (1 - $$9) + $$10 ) >= 0.99) {print $$0}}' > $(snapeCombinedOut)

.PHONY: snape-combined

snape-combined: $(snapeCombinedOut)

# Run SNAPE for each individual smaple, only need to consider the polymorphic sites previously identified

polySites=$(SNAPEDir)/polymorphic.sites

$(polySites): $(snapeCombinedOut)
	cut -f1,2 $(snapeCombinedOut) > $(polySites)

samplesSNAPEDir=$(SNAPEDir)/samples

$(samplesSNAPEDir):
	if [ ! -d $(samplesSNAPEDir) ]; then mkdir $(samplesSNAPEDir); fi

samplesSNAPEInFiles=$(addsuffix .pileup,$(subst $(alignDir),$(samplesSNAPEDir),$(alignments)))


$(samplesSNAPEInFiles): $(alignments) $(polySites) $(srGenome) | $(samplesSNAPEDir)
	conda run --no-capture-output -n rssw-minimap2-samtools samtools mpileup -f $(srGenome) --positions $(polySites) $(subst $(samplesSNAPEDir),$(alignDir),$(basename $@)) > $@


.PHONY: pileups

pileups: $(samplesSNAPEInFiles)

samplesSNAPEOutFiles=$(subst .pileup,.out,$(samplesSNAPEInFiles))

$(samplesSNAPEOutFiles): $(samplesSNAPEInFiles)
	cat $(subst .out,.pileup,$@) | $(SNAPEBin) -nchr 60 -fold folded -priortype flat -trust 1 > $@


.PHONY: snape-samples

snape-samples: $(samplesSNAPEOutFiles)

## Prep files for poolfstat

## Pool fstat accepts a VCF file with AD fields to provide read counts.
## BCFtools mpileup can produce the needed VCF, and we can give it a list of sites to include
## Here, produce a VCF from the polymorphic sites identified by SNAPE



fstatDir=poolFstat


$(fstatDir):
	if [ ! -d $(fstatDir) ]; then mkdir $(fstatDir); fi


#includedSitesList=$(fstatDir)/includedSites

polymorphicSitesVCF=$(fstatDir)/includedSites.vcf

$(polymorphicSitesVCF): $(polySites) $(alignments) $(srGenome) | $(fstatDir)
	conda run --no-capture-output -n rssw-bcftools bcftools mpileup -R $(polySites) --skip-indels  --fasta-ref $(srGenome) -a FORMAT/AD,INFO/AD $(alignments)  > $(polymorphicSitesVCF)

.PHONY: vcf

vcf: $(polymorphicSitesVCF)

