#
# Flye assembly. Deduplicated with redundans, but not scaffolded.
#

assemblyNoScaff=../assembly/flyeRedundansNoReads/scaffolds.reduced.fa

# Make the blast db
# Sould just be a regulat blast database

dbNoScaff=noScaffolding

#blast database header file, to use as the make target
dbNoScaffHeader=$(dbNoScaff).nhr

$(dbNoScaffHeader): $(assemblyNoScaff)
	conda run --no-capture-output -n rssw-repeatmodeler BuildDatabase -name $(dbNoScaff) $(assemblyNoScaff)

.PHONY: buildDBNoScaff

buildDBNoScaff: $(dbNoScaffHeader)

# Run Repeatmodeler on the database

# Repeatmodeler produces several output files, named after the input database.
# Use the FASTA format output as the target
repeatModelerNoScaffOutFile=$(dbNoScaff)-families.fa

$(repeatModelerNoScaffOutFile): $(dbNoScaffHeader)
	conda run --no-capture-output -n rssw-repeatmodeler RepeatModeler -pa 10 -LTRStruct -database $(dbNoScaff)

.PHONY: repeatModelerNoScaff

repeatModelerNoScaff: $(repeatModelerNoScaffOutFile)

# Run repeat masker using the repeats identified by repeatmasker

# Produces various output files, use the .masked file as the target

repeatMaskerNoScaffOutDir=maskedNoScaff

$(repeatMaskerNoScaffOutDir):
	if [ ! -d $(repeatMaskerNoScaffOutDir) ]; then mkdir $(repeatMaskerNoScaffOutDir); fi

repeatMaskerNoScaffOut=$(repeatMaskerNoScaffOutDir)/$(notdir $(assemblyNoScaff)).masked

$(repeatMaskerNoScaffOut): $(repeatModelerNoScaffOutFile) | $(repeatMaskerNoScaffOutDir)
	conda run --no-capture-output -n rssw-repeatmasker RepeatMasker -lib $(repeatModelerNoScaffOutFile) -dir $(repeatMaskerNoScaffOutDir) -par 28 -gff $(assemblyNoScaff)

.PHONY: maskNoScaff

maskNoScaff: $(repeatMaskerNoScaffOut)

maskedNoScaffStats=$(repeatMaskerNoScaffOutDir)/stats.txt

$(maskedNoScaffStats): $(repeatMaskerNoScaffOut)
	conda run -n rssw-assemblyStats assembly-stats $(repeatMaskerNoScaffOut) > $(maskedNoScaffStats)

.PHONY: stats

stats: $(maskedNoScaffStats)

BUSCOLineage=endopterygota_odb10

BUSCONoScaffOutDir=busco_NoScaff

BUSCONoScaffOutFile=$(BUSCONoScaffOutDir)/run_$(BUSCOLineage)/full_table.tsv

BUSCOOpts= --mode genome --augustus --long --lineage $(BUSCOLineage) --cpu 56

$(BUSCONoScaffOutFile): $(repeatMaskerNoScaffOut)
	conda run --no-capture-output -n rssw-busco busco -i $(repeatMaskerNoScaffOut) $(BUSCOOpts) --out $(BUSCONoScaffOutDir)

.PHONY: busco-analysis-noScaff

busco-analysis-noScaff: $(BUSCONoScaffOutFile)
