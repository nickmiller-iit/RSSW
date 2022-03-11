# Assemble red sunflower seed weevil genome from PacBio Hifi reads.


# Input read data

readDir=reads
hifiReadFiles=$(readDir)/weevil_2_m64108e_211111_063517.hifi_reads.fastq.gz $(readDir)/weevil_m64108e_211030_220410.hifi_reads.fastq.gz

# Run fastqc to check read data

fastqcDir=fastqc_out

$(fastqcDir):
	if [ ! -d $(fastqcDir) ]; then mkdir $(fastqcDir); fi

fastqcFiles=$(subst .fastq.gz,_fastqc.html,$(subst $(readDir)/,$(fastqcDir)/,$(hifiReadFiles)) )

fastqcOpts= -o $(fastqcDir) -t 16

$(fastqcFiles): $(hifiReadFiles) | $(fastqcDir)
	conda run -n rssw-fastqc fastqc $(fastqcOpts) $(hifiReadFiles)

.PHONY: fastqc

fastqc: $(fastqcFiles)
