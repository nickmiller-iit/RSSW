# Annotation

A secondary goal of the project is to identify genes potentially involved in pyrethroid resistance. Specifically:

 1. Voltage grated sodium channel. We can look for polymorphisms that might be related to target site insensitivity.
 2. Cytochrom P450s. A common detoxification mechanism. Really just a catalog at this stage, but potentially useful for follow-up work & proposals.
 
Most of the heavy lifting was already done by Paulina. However, we need to re-run with the poished and scaffolded genome.

We do not exprect to get phenomnal results here. Paulina found that substantial chunks of the sodium channel gene were missing from the assembly and a good number of CYPs were partial genes.

## Gene model prediction with BRAKER2

Basic steps are.

 1. Mask off repeats (interspersed repeats only, not low complexity regions).
 2. Align RNA-Seq data to soft masked genome with HiSat 2 to train BRAKER
 3. Run BRAKER2 to generate gene models.

Braker can be installed via conda, but there are some additional things that have to be installind into the environment"


 * GeneMark
 * GeneThreader
 * PERL MCE module

### RNA-Seq only

For a first run, ran BRAKER2 with only the aligned RNA-Seq data. It did throw up a warning about there being too few "good" genes.

At the end of the run, there were a total of 45,533 predicted proteins - substantially more than there should be. Running a BUSCO analysis on the predicted proteins, we get:

	C:41.1%[S:35.1%,D:6.0%],F:16.2%,M:42.7%,n:2124
	874	Complete BUSCOs (C)
	746	Complete and single-copy BUSCOs (S)
	128	Complete and duplicated BUSCOs (D)
	345	Fragmented BUSCOs (F)
	905	Missing BUSCOs (M)
	2124	Total BUSCO groups searched

This is not great - a lot of missing BUSCOs. This is roughly the same as Paulina got with the unscaffolded genome assembly. **However** it is significantly worse than the BUSCO analysis we ran on the unannotated assembly (which wasn't great).

I suspect the issue is low RNA-Seq coverage - BRAKER explicitly warned about too few genes. Since BRAKER2 will also use protein sequences from related species, we can try that. In the past, playing around with the proteins that make up the BUSCO set did not improve matters greatly. We could, as an alternative try predicted proteins from a decent weevil genome assembly. The boll weevil genome (GCF_022605725.1) probably fits the bill best here.

Annotation using the boll weevil proteins gives us an annotation with 50,192 predicted proteins

The BUSCO analysis gives us:

	C:51.1%[S:43.5%,D:7.6%],F:13.8%,M:35.1%,n:2124
	1087	Complete BUSCOs (C)
	925	Complete and single-copy BUSCOs (S)
	162	Complete and duplicated BUSCOs (D)
	293	Fragmented BUSCOs (F) 
	744	Missing BUSCOs (M)
	2124	Total BUSCO groups searched
	
A modest improvement, but not spectacular.

Fundamentaly, the problem is a genome assembled from low coverage sequencing just isn't all that great. This was pretty much expected from the outset.

