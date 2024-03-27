# Diamond search for sodium channel parts in BRAKER predicted proteins

brakerProteins=../annotation/braker.proteins.fasta

diamondDb=$(subst fasta,dmnd,$(notdir $(brakerProteins)))

$(diamondDb): $(brakerProteins)
	conda run --no-capture-output -n rssw_diamond diamond makedb --in $(brakerProteins) --db $(basename $(diamondDb))

.PHONY: diamond-database

diamond-database: $(diamondDb)

##Example sodium channel protein sequences

exampleChannels=Q94615 A0A6J2XC81 A0A834MPJ1 U4U5N9

exampleChannelsFASTADir=exampleChannels

$(exampleChannelsFASTADir):
	if [ ! -d $(exampleChannelsFASTADir) ]; then mkdir $(exampleChannelsFASTADir); fi

exampleChannelsFASTA=$(addprefix $(exampleChannelsFASTADir)/,$(addsuffix .fasta,$(exampleChannels)))

$(exampleChannelsFASTA): | $(exampleChannelsFASTADir)
	wget -P $(exampleChannelsFASTADir) $(subst $(exampleChannelsFASTADir),https://rest.uniprot.org/uniprotkb,$@)

.PHONY: downloadExampleChannels

downloadExampleChannels: $(exampleChannelsFASTA)

exampleChannelsHitsDir=diamondHits

$(exampleChannelsHitsDir):
	if [ ! -d $(exampleChannelsHitsDir) ]; then mkdir $(exampleChannelsHitsDir); fi

exampleChannelHits=$(addprefix $(exampleChannelsHitsDir)/,$(addsuffix .hits,$(exampleChannels)))

diamondOPTs=--threads 6 --outfmt 0

$(exampleChannelHits): $(exampleChannelsFASTA) | $(exampleChannelsHitsDir)
	conda run --no-capture-output -n rssw_diamond diamond blastp $(diamondOPTs) --db $(diamondDb) --query $(subst hits,fasta,$(subst $(exampleChannelsHitsDir),$(exampleChannelsFASTADir),$@)) > $@

.PHONY: diamond_hits

diamond_hits: $(exampleChannelHits)

# Extracting RSSW diamond hits

## NBB hits are taken from results of diamond blastp

RSSWProteinsDir=putativeChannelProteins

$(RSSWProteinsDir):
	if [ ! -d $(RSSWProteinsDir) ]; then mkdir $(RSSWProteinsDir); fi

RSSWProteins=jg42936.t1 jg12353.t1

RSSWProteinsFasta=$(addprefix $(RSSWProteinsDir)/,$(addsuffix .fasta,$(RSSWProteins)))

$(RSSWProteinsFasta): | $(RSSWProteinsDir)
	conda run --no-capture-output -n rssw-seqkit seqkit grep $(brakerProteins) -p $(basename $(notdir $@)) > $@

.PHONY: extractPutatativeChannelProts

extractPutatativeChannelProts: $(RSSWProteinsFasta)

.PHONY: test

test:
	echo $(RSSWProteinsFasta)
