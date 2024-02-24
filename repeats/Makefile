#
# Flye assembly. Deduplicated with redundans, polished with pilon and scaffolded with rascaff.
#

assembly=../assembly/RSSWDraftGenome.fasta

# Make the blast db
# Sould just be a regulat blast database

BLASTdb=RSSW

#blast database header file, to use as the make target
BLASTdbHeader=$(BLASTdb).nhr

$(BLASTdbHeader): $(assembly)
	conda run --no-capture-output -n rssw-repeatmodeler BuildDatabase -name $(BLASTdb) $(assembly)

.PHONY: buildBLASTdb

buildBLASTdb: $(BLASTdbHeader)

# Run Repeatmodeler on the database

# Repeatmodeler produces several output files, named after the input database.
# Use the FASTA format output as the target
repeatModelerOutFile=$(BLASTdb)-families.fa

$(repeatModelerOutFile): $(BLASTdbHeader)
	conda run --no-capture-output -n rssw-repeatmodeler RepeatModeler -pa 10 -LTRStruct -database $(BLASTdb)

.PHONY: repeatModeler

repeatModeler: $(repeatModelerOutFile)

# Run repeat masker using the repeats identified by repeatmasker

# Produces various output files, use the .masked file as the target

repeatMaskerOutDir=masked

$(repeatMaskerOutDir):
	if [ ! -d $(repeatMaskerOutDir) ]; then mkdir $(repeatMaskerOutDir); fi

repeatMaskerOut=$(repeatMaskerOutDir)/$(notdir $(assembly)).masked

$(repeatMaskerOut): $(repeatModelerOutFile) | $(repeatMaskerOutDir)
	conda run --no-capture-output -n rssw-repeatmasker RepeatMasker -lib $(repeatModelerOutFile) -dir $(repeatMaskerOutDir) -par 28 -gff $(assembly)

.PHONY: mask

mask: $(repeatMaskerOut)

maskedStats=$(repeatMaskerOutDir)/stats.txt

$(maskedStats): $(repeatMaskerOut)
	conda run -n rssw-assemblyStats assembly-stats $(repeatMaskerOut) > $(maskedStats)

.PHONY: stats

stats: $(maskedStats)

BUSCOLineage=endopterygota_odb10

BUSCOOutDir=busco

BUSCOOutFile=$(BUSCOOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCOOutFile): $(repeatMaskerOut)
	conda run --no-capture-output -n rssw-busco busco -i $(repeatMaskerOut) $(BUSCOOpts) --out $(BUSCOOutDir)

.PHONY: busco-analysis

busco-analysis: $(BUSCOOutFile)
