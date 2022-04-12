# Notes on red sunflower seed weevil genome assembly

## Insects

Jarrad Prasifka collected larvae from ~ 10 sunflower heads. Larvae were starved for > 60 hours over a weekend. A total of 17 larvae were pooled for DNA extraction by the UIUC core facility.

## Sequencing libraries

UIUC ended up preparing 2 PacBio HiFi libraries. The first one performed poorly. They ran it twice, tweaking the run parameters but only managed to get ~701 MB (weevil_m64108e_211030_220410.hifi_reads.fastq.gz), and 1.6 Gb (weevil_m64108e_211030_220410.hifi_reads.fastq.gz) of total data on each run. Average read lengths were also a bit short: 7.8kb and 7.9 kb respectively.

They made a second library from a pool of 16 larvae, with thorough DNA cleaning (Weevil_m64108e_220407_204305.hifi_reads.fastq.gz), that performed much better, yeilding 30.1 Gb total read data and mean read length of 11.4 kb.

## Assembly

For an initial assembly, just used the data from the "good library". Adding the other 2 runs contributes very little in terms of extra coverage and rists adding some suspect data into the mix. Furthermore, since the 2 libraries were prepared from different pools of individuals, mixing libraries will increase the genetic variation in the assembly data.

Inital assembly was done with flye 2.8 with defaullt params for hifi data.
