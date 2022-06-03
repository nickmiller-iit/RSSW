# Blobtools QC of assemblies

Blobtools provides some nice plots to help QC and troubleshoota assemblies. Decided to put this part in a separate dir, rather than in with the assemblies because blobtools need quite a lot of stuff, including local blast/diamond databases.

## Diamond databases

Set these up with their own makefile, to help keep things organized. Databases need to include taxonomic information. Used the instructions found at https://www.uppmax.uu.se/resources/databases/diamond-protein-alignment-databases/ and https://blobtools.readme.io/docs/taxid-mapping-file as a basis for this.

### Database choice

The main thing we want from blobtools is to detect contigs that are obvious contaminants, mostly gut microorganisms. This means we don't need super precise taxonomy assignments. It would also be good to use a resonably small database to keep the search time reasonable. As a first try, go with UniRef 90.

### Taxid files

Blobtools can add taxonomic infor to the results of a diamond or blast search. It needs a tsv file with mappings between sequence IDs ans NCBI taxonomy numbers. Fortunately, the UniRef 90 sequence headers include a field `TaxID=`, which gives the NCBI taxonomy.
