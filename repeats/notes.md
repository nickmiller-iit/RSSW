# Identifying and masking repeats

We will want to do this both for annotation and for alignment and analysis of pool-seq data.

At the time of writing, we have 2 genome assemblies made with flye. Both were further deduplicated using `redundans`. One assembly was deduplicate using the input read data for scaffolding, the other did not. It is not clear at this stage which is preferable.

## Unscaffolded assembly.

First step, ran repeatmodeler on the unscaffolded, deduplicated assembly.
