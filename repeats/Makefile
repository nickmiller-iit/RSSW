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
# Use the "Stockholm" format output as the target
repeatModelerNoScaffOutFile=$(dbNoScaff)-families.stk

$(repeatModelerNoScaffOutFile): $(dbNoScaffHeader)
	conda run --no-capture-output -n rssw-repeatmodeler RepeatModeler -pa 10 -LTRStruct -database $(dbNoScaff)

.PHONY: repeatModelerNoScaff

repeatModelerNoScaff: $(repeatModelerNoScaffOutFile)
