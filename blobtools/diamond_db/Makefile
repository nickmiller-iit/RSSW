# Diamond databse for UniRef 90

UniProtDir=uniprot

$(UniProtDir):
	if [ ! -d $(UniProtDir) ]; then mkdir $(UniProtDir); fi

UniRef90=uniref90.fasta.gz

UniRef90Download=$(UniProtDir)/$(UniRef90)

$(UniRef90Download): | $(UniProtDir)
	wget -O $(UniRef90Download) ftp.uniprot.org/pub/databases/uniprot/uniref/uniref90/uniref90.fasta.gz

.PHONY: dl

dl: $(UniRef90Download)

UniRef90Diamond=$(UniProtDir)/uniref90.dmnd

$(UniRef90Diamond): $(UniRef90Download)
	conda run --no-capture-output -n rssw_diamond diamond makedb --in $(UniRef90Download) --db $(UniRef90Diamond)

.PHONY: uniref90db

uniref90db: $(UniRef90Diamond)

# TaxIDs file for UniRef90

UniRef90TaxIDs=$(UniProtDir)/uniref90.txid


#NBB Python script assumes gzipped fasta input, doesn't do any checking
$(UniRef90TaxIDs): $(UniRef90Download)
	python uniprot2txid.py $(UniRef90Download) > $(UniRef90TaxIDs)

.PHONY: uniref90txids

uniref90txids: $(UniRef90TaxIDs)

# NodesDB File - can be shared by databases

NCBITaxDump=taxdump.tar.gz

$(NCBITaxDump):
	wget -O $(NCBITaxDump) ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz

.PHONY: dltaxdump

dltaxdump: $(NCBITaxDump)

# taxdump tarball contains a bunch of files, we need nodes.dmp and names.dmp. Use nodes.dmp as the target

nodes.dmp: $(NCBITaxDump)
	tar xzvf $(NCBITaxDump)

# NodesDB file. Simplified consolidation of nodes.dmp and names.dmp

nodesDB=nodes.db

$(nodesDB): nodes.dmp
	cat mknodesdb.sql | sqlite3 -batch | tr -s "\t" > $(nodesDB)

.PHONY: nodesdb

nodesdb: $(nodesDB)
