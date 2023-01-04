# Read trimming and QC

## The raw data

readsDir=data

rawReadsDir=$(readsDir)/raw

B1Raw=$(rawReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz
B2Raw=$(rawReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz
D1Raw=$(rawReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz
D2Raw=$(rawReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz
H1Raw=$(rawReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_1.fq.gz
H2Raw=$(rawReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_2.fq.gz
K1Raw=$(rawReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_1.fq.gz
K2Raw=$(rawReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_2.fq.gz
L1Raw=$(rawReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_1.fq.gz
L2Raw=$(rawReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_2.fq.gz
O1Raw=$(rawReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_1.fq.gz
O2Raw=$(rawReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_2.fq.gz
#O1RawExtra=$(rawReadsDir)/O_CKDN220061314-1A_HMMYMDSX5_L2_1.fq.gz
#O2RawExtra=$(rawReadsDir)/O_CKDN220061314-1A_HMMYMDSX5_L2_2.fq.gz
S1Raw=$(rawReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_1.fq.gz
S2Raw=$(rawReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_2.fq.gz
T1Raw=$(rawReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_1.fq.gz
T2Raw=$(rawReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_2.fq.gz

BRaw=$(B1Raw) $(B2Raw)
DRaw=$(D1Raw) $(D2Raw)
HRaw=$(H1Raw) $(H2Raw)
KRaw=$(K1Raw) $(K2Raw)
LRaw=$(L1Raw) $(L2Raw)
ORaw=$(O1Raw) $(O2Raw)
#ORawExtra=$(O1RawExtra) $(O2RawExtra)
SRaw=$(S1Raw) $(S2Raw)
TRaw=$(T1Raw) $(T2Raw)

#allRawReads=$(BRaw) $(DRaw) $(HRaw) $(KRaw) $(LRaw) $(ORaw) $(ORawExtra) $(SRaw) $(TRaw)
allRawReads=$(BRaw) $(DRaw) $(HRaw) $(KRaw) $(LRaw) $(ORaw) $(SRaw) $(TRaw)

## QC the raw data

rawQCDir=$(rawReadsDir)/QC

$(rawQCDir):
	if [ ! -d $(rawQCDir) ]; then mkdir $(rawQCDir); fi

rawQCFiles=$(subst fq.gz,_fastqc.html,$(subst $(rawReadsDir)/,$(rawQCDir)/,$(allRawReads)))

fastQCOpts= -t 16

$(rawQCFiles): $(allRawReads) | $(rawQCDir)
	conda run --no-capture-output -n rssw-fastqc fastqc $(fastQCOpts) -o $(rawQCDir) $(subst _fastqc.html,fq.gz,$(subst $(rawQCDir)/,$(rawReadsDir)/,$@))

.PHONY: qcRaw

qcRaw: $(rawQCFiles)

## Trim/clip the raw reads

trimmedReadsDir=$(readsDir)/trimmed

$(trimmedReadsDir):
	if [ ! -d $(trimmedReadsDir) ]; then mkdir $(trimmedReadsDir); fi



B1Trimmed=$(trimmedReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_1.fq.gz
B2Trimmed=$(trimmedReadsDir)/B_CKDN220061309-1A_HMN35DSX5_L4_2.fq.gz
D1Trimmed=$(trimmedReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_1.fq.gz
D2Trimmed=$(trimmedReadsDir)/D_CKDN220061310-1A_HK7YTDSX5_L2_2.fq.gz
H1Trimmed=$(trimmedReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_1.fq.gz
H2Trimmed=$(trimmedReadsDir)/H_CKDN220061311-1A_HK7KHDSX5_L1_2.fq.gz
K1Trimmed=$(trimmedReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_1.fq.gz
K2Trimmed=$(trimmedReadsDir)/K_CKDN220061312-1A_HK7Y5DSX5_L2_2.fq.gz
L1Trimmed=$(trimmedReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_1.fq.gz
L2Trimmed=$(trimmedReadsDir)/L_CKDN220061313-1A_HK7MLDSX5_L1_2.fq.gz
O1Trimmed=$(trimmedReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_1.fq.gz
O2Trimmed=$(trimmedReadsDir)/O_CKDN220061314-1A_HK7MLDSX5_L2_2.fq.gz
S1Trimmed=$(trimmedReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_1.fq.gz
S2Trimmed=$(trimmedReadsDir)/S_CKDN220061315-1A_HK7Y5DSX5_L2_2.fq.gz
T1Trimmed=$(trimmedReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_1.fq.gz
T2Trimmed=$(trimmedReadsDir)/T_CKDN220061316-1A_HK7YTDSX5_L2_2.fq.gz

# Use the read 1 files as the targets to make. We are unlikely to want to make trimmed read 1 without also making trimmed read 2

trimmedRead1=$(B1Trimmed) $(D1Trimmed) $(H1Trimmed) $(K1Trimmed) $(L1Trimmed) $(O1Trimmed) $(S1Trimmed) $(T1Trimmed)
trimmedRead2=$(B2Trimmed) $(D2Trimmed) $(H2Trimmed) $(K2Trimmed) $(L2Trimmed) $(O2Trimmed) $(S2Trimmed) $(T2Trimmed)

allTrimmedReads=$(trimmedRead1) $(trimmedRead2)

fastpOpts= -3 -5 -l 30



$(trimmedRead1): $(allRawReads) | $(trimmedReadsDir)
	conda run --no-capture-output -n rssw-fastp fastp $(fastpOpts) --in1 $(subst $(trimmedReadsDir),$(rawReadsDir),$@)  --out1 $@ --in2 $(subst _1.fq,_2.fq,$(subst $(trimmedReadsDir),$(rawReadsDir),$@))  --out2 $(subst _1.fq,_2.fq,$@)

.PHONY: trim

trim: $(trimmedRead1)


trimmedQCDir=$(trimmedReadsDir)/QC

$(trimmedQCDir):
	if [ ! -d $(trimmedQCDir) ]; then mkdir $(trimmedQCDir); fi

trimmedQCFiles=$(subst fq.gz,_fastqc.html,$(subst $(trimmedReadsDir)/,$(trimmedQCDir)/,$(allTrimmedReads)))

fastQCOpts= -t 16

$(trimmedQCFiles): $(allTrimmedReads) | $(trimmedQCDir)
	conda run --no-capture-output -n rssw-fastqc fastqc $(fastQCOpts) -o $(trimmedQCDir) $(subst _fastqc.html,fq.gz,$(subst $(trimmedQCDir)/,$(trimmedReadsDir)/,$@))

.PHONY: qcTrimmed

qcTrimmed: $(trimmedQCFiles)
