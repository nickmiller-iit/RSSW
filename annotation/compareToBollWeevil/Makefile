# Download the predicted boll weevil protein set from NCBI

bollWeevilProteins=bollWeevilProteins.fasta

$(bollWeevilProteins):
	conda run --no-capture-output -n rssw-ncbi-datasets datasets download genome accession GCF_022605725.1 --include protein
	unzip ncbi_dataset.zip
	mv ncbi_dataset/data/GCF_022605725.1/protein.faa $(bollWeevilProteins)
	rm -r ncbi_dataset
	rm README.md md5sum.txt ncbi_dataset.zip

.PHONY: bollweevil_prots

bollweevil_prots: $(bollWeevilProteins)
