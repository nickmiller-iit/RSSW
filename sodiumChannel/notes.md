# Looking for the putative voltage-gated sodium channel and variant sites therein

## Looking for parts of sodium channel in the BRAKER2 annotations

First step is to see what, if anything of the sodium channel we have in our braker annotations. A good start point is to use diamond to seach the BRAKER2 predicted proteins using sodium channel protein sequences from other species.

### Example sodium channel genes

To get some example sodium channel proteins, started out with the *Musca domestica* (housefly) as this is the canonical protein for kdr mutations. Got the housfly para-like voltage gated sodium channel protein from UniProt: Q94615. Then used this as a query for UniProt BLAST. Filtered the results to Curculionidae and picked example proteins from the hits. Final list of example sodium channel proteins is

Q94615: *Musca domestica* (Housefly)
A0A6J2XC81: *Sitophilus oryzae* (Rice weevil)
A0A834MPJ1: *Rhynchophorus ferrugineus* (Red palm weevil)
U4U5N9: *Dendroctonus ponderosae* (Mountain pine beetle)

### Diamond searches

Running diamond blastp with each of the example proteins produces hits to two predicted proteins:

 * jg42936.t1 1688 amino acids, scaffold = scaffold_26039 
 * jg12353.t1 1418 amino acids, scaffold = scaffold_266
 
 Running both of these prtein sequences through uniprot blast and interpro scan on the web indicates that jg42936.t1 is the voltage gated sodium channel alpha subunit, whereas jg12353.t1 is a "sodium leak channel"
 
However, multiple sequence alignment to the example sodium channles looks pretty nasty, lots if divergent residues
 
