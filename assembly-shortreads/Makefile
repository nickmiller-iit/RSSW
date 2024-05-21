# Assembly of contigs with minia



# Use the Trimmed reads from each pool as input
# These were already produced for mapping pool-seq data to long read assembly
# For convenience, concatenate reads from separate pools

#leftTrimmedReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz  ../poolseq/data/trimmed/L_CKDN220061313-1A_HK7MLDSX5_L1_1.fq.gz ../poolseq/data/trimmed/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz  ../poolseq/data/trimmed/O_CKDN220061314-1A_HK7MLDSX5_L2_1.fq.gz ../poolseq/data/trimmed/H_CKDN220061311-1A_HK7KHDSX5_L1_1.fq.gz  ../poolseq/data/trimmed/S_CKDN220061315-1A_HK7Y5DSX5_L2_1.fq.gz ../poolseq/data/trimmed/K_CKDN220061312-1A_HK7Y5DSX5_L2_1.fq.gz  ../poolseq/data/trimmed/T_CKDN220061316-1A_HK7YTDSX5_L2_1.fq.gz

#rightTrimmedReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz  ../poolseq/data/trimmed/L_CKDN220061313-1A_HK7MLDSX5_L1_2.fq.gz ../poolseq/data/trimmed/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz  ../poolseq/data/trimmed/O_CKDN220061314-1A_HK7MLDSX5_L2_2.fq.gz ../poolseq/data/trimmed/H_CKDN220061311-1A_HK7KHDSX5_L1_2.fq.gz  ../poolseq/data/trimmed/S_CKDN220061315-1A_HK7Y5DSX5_L2_2.fq.gz ../poolseq/data/trimmed/K_CKDN220061312-1A_HK7Y5DSX5_L2_2.fq.gz  ../poolseq/data/trimmed/T_CKDN220061316-1A_HK7YTDSX5_L2_2.fq.gz


leftTrimmedReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz ../poolseq/data/trimmed/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz
rightTrimmedReads=../poolseq/data/trimmed/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz ../poolseq/data/trimmed/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz


readsDir=poolseqReads

$(readsDir):
	if [ ! -d $(readsDir) ]; then mkdir $(readsDir); fi

leftReads=$(readsDir)/left.fq.gz

rightReads=$(readsDir)/right.fq.gz

repeats=../repeats/RSSW-families.fa


# Reads are filtered to remove those that map to repears identified by repeat modeler. This should remove around 45% of reads.
# Note that we use the left feads file as the trigger. Right reads file is automatically made by the same rule
# Using fifos to save both time and disk space
# Two pools is a roughly 60X coverage, but this is a bit more than we can assemble with available
# memory. The -s argument to samtools view subsamples to give us roughly 50X.
$(leftReads): $(leftTrimmedReads) $(rightTrimmedReads) | $(readsDir)
	mkfifo $(readsDir)/l.fastq
	zcat $(leftTrimmedReads) > $(readsDir)/l.fastq&
	mkfifo $(readsDir)/r.fastq
	zcat $(rightTrimmedReads) > $(readsDir)/r.fastq&
	conda run --no-capture-output -n rssw-minimap2-samtools minimap2 -t 28 -ax sr $(repeats) $(readsDir)/l.fastq $(readsDir)/r.fastq  | \
	conda run --no-capture-output -n rssw-minimap2-samtools samtools view -f 12 -b -s 0.83 | \
	conda run --no-capture-output -n rssw-minimap2-samtools samtools sort -n -o $(readsDir)/tmp.bam
	conda run --no-capture-output -n rssw-minimap2-samtools samtools fastq -1 $(leftReads) -2 $(rightReads) $(readsDir)/tmp.bam
	rm $(readsDir)/tmp.bam $(readsDir)/l.fastq $(readsDir)/r.fastq


.PHONY: reads
reads: $(leftReads)

miniaAssemblyDir=minia-assembly

$(miniaAssemblyDir):
	if [ ! -d $(miniaAssemblyDir) ]; then mkdir $(miniaAssemblyDir); fi

miniaAssembly=$(miniaAssemblyDir)/assembly_final.contigs.fa

miniaPipeline=gatb-minia-pipeline/gatb

$(miniaAssembly): $(leftReads) | $(miniaAssemblyDir)
	conda run --no-capture-output -n rssw-minia-pipeline $(miniaPipeline) --no-scaffolding -1 $(leftReads) -2 $(rightReads)
	mv assembly* $(miniaAssemblyDir)


assemble:$(miniaAssembly)

## initial minia assembly is very fragmented, which is to be expected probably lots of redundant haplotypes too.
## Try running redundans on initial scaffolds
## Don't attempt to scaffold yet

redundansOutDir=redundansOut

redundansOutput=$(redundansOutDir)/contigs.reduced.fa

#redundansOpts=--threads 54 --mem 128 --longreads $(assemblyHifiReads) --outdir $(redundansOutDir)
redundansOpts=--threads 54 --mem 128  --outdir $(redundansOutDir) --noscaffolding --nogapclosing


$(redundansOutput): $(deconOut)
	conda run --no-capture-output -n rssw-redundans redundans.py $(redundansOpts) -f $(miniaAssembly)

.PHONY: deduplicate

deduplicate: $(redundansOutput)

## Scaffold the deduplicate contigs using ntLink

## NtLink requires input contigs and long reads to be in the working directory
## It also hard codes output names. Solution is to create symlinks for input, run scaffolding, move output to
## an output dir.

scaffoldDir=scaffolded

$(scaffoldDir):
	if [ ! -d $(scaffoldDir) ]; then mkdir $(scaffoldDir); fi

scaffoldInputContigs=$(redundansOutput)

scaffoldLongReads=../assembly/reads/Weevil_m64108e_220407_204305.hifi_reads.fastq.gz

scaffoldOutput=$(scaffoldDir)/scaffolds.fa

# z is minimum length of contig to scaffold
ntLinkOpts=z=400

$(scaffoldOutput): $(scaffoldInputContigs) $(scaffoldLongReads) | $(scaffoldDir)
	ln -s $(scaffoldInputContigs) ./
	ln -s $(scaffoldLongReads) ./
	conda run --no-capture-output -n rssw-ntlink ntLink scaffold target=$(notdir $(scaffoldInputContigs)) reads=$(notdir $(scaffoldLongReads)) $(ntLinkOpts)
	rm $(notdir $(scaffoldInputContigs)) $(notdir $(scaffoldLongReads))
	mv $(notdir $(scaffoldInputContigs))* $(scaffoldDir)/


.PHONY: scaffold

scaffold: $(scaffoldOutput)
