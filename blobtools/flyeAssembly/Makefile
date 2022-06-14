# Try out with the flye assembly, prior to redundans

targetAssembly=../../assembly/flyeAssembly/assembly.fasta

# Hits file for diamond seach against Uniref90

diamondOpts=--outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore --max-target-seqs 1 --sensitive --threads 28 --evalue 1e-25

diamondDb=../diamond_db/uniprot/uniref90.dmnd

hitsFile=$(notdir $(targetAssembly)).uniref90.hits

# NB dependencies built elsewhere
$(hitsFile): $(targetAssembly) $(diamondDb)
	conda run --no-capture-output -n rssw_diamond diamond blastx $(diamondOpts) --db $(diamondDb) --query $(targetAssembly) > $(hitsFile)

.PHONY: diamondhits

diamondhits: $(hitsFile)

# use blobtools taxify module to make hits file with tax IDs

Uniref90TxIDMappings=../diamond_db/uniprot/uniref90.txid

taxifiedHitsFile=$(hitsFile).taxified.out

$(taxifiedHitsFile): $(hitsFile) $(Uniref90TxIDMappings)
	 conda run --no-capture-output -n rssw-blobtools blobtools taxify --hit_file $(hitsFile) --taxid_mapping_file $(Uniref90TxIDMappings) --map_col_sseqid 0 --map_col_taxid 1

.PHONY: taxify

taxify: $(taxifiedHitsFile)

# Read mapping for coverage stats
#
# Can use SAM or BAM. Use BAM to save disk space

hifiReadsFile=../../assembly/reads/Weevil_m64108e_220407_204305.hifi_reads.fastq.gz

mappedReadsFile=$(notdir $(targetAssembly)).bam

$(mappedReadsFile): $(targetAssembly) $(hifiReadsFile)
	conda run --no-capture-output -n rssw-minimap2 minimap2 -t 28 -ax map-pb $(targetAssembly) $(hifiReadsFile) > tmp.sam
	conda run --no-capture-output -n rssw-samtools samtools view -b tmp.sam > tmp.bam
	conda run --no-capture-output -n rssw-samtools samtools sort -@ 28 tmp.bam > $(mappedReadsFile)
	rm tmp.sam tmp.bam

.PHONY: map

map: $(mappedReadsFile)

# Index the BAM file. Documentation doesn't say this is needed, but blobtools fails otherwise

mappedReadsIndex=$(mappedReadsFile).bai

$(mappedReadsIndex): $(mappedReadsFile)
	conda run --no-capture-output -n rssw-samtools samtools index -@ 28 $(mappedReadsFile)

.PHONY: index

index: $(mappedReadsIndex)

# the blobtools "database"

blobDBFile=$(notdir $(targetAssembly)).blobDB.json

$(blobDBFile): $(targetAssembly) $(taxifiedHitsFile) $(mappedReadsIndex)
	conda run --no-capture-output -n rssw-blobtools blobtools create \
	--infile $(targetAssembly) \
	--hitsfile $(taxifiedHitsFile) \
	--bam $(mappedReadsFile) \
	--nodes ../diamond_db/nodes.dmp \
	--names ../diamond_db/names.dmp \
	--out $(notdir $(targetAssembly))

.PHONY: blobdb

blobdb: $(blobDBFile)

# make the blob plot

phylumBlobPlot=$(notdir $(targetAssembly)).phylum.png

$(phylumBlobPlot): $(blobDBFile)
	conda run --no-capture-output -n rssw-blobtools blobtools plot  -i $(blobDBFile) --rank phylum
	mv $(blobDBFile).bestsum.phylum.p8.span.100.blobplot.bam0.png $(phylumBlobPlot)

superkingdomBlobPlot=$(notdir $(targetAssembly)).superkingdom.png

$(superkingdomBlobPlot): $(blobDBFile)
	conda run --no-capture-output -n rssw-blobtools blobtools plot  -i $(blobDBFile) --rank superkingdom
	mv $(blobDBFile).bestsum.superkingdom.p8.span.100.blobplot.bam0.png $(superkingdomBlobPlot)

.PHONY: blobplots

blobplots: $(phylumBlobPlot) $(superkingdomBlobPlot)
