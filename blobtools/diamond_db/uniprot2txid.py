import sys
import gzip
inFileName = sys.argv[1]
infile = gzip.open(inFileName, 'rt')
for line in infile:
    if line.startswith(">"):
        headerElements = line.split(' ')
        seqID = headerElements[0].strip(">")
        #gets the position of the first element to start with "TaxID=". there should only be one
        txIDPos = [x.startswith("TaxID=") for x in headerElements].index(True)
        txID = headerElements[txIDPos].split("=")[1]
        print(seqID + '\t' + txID)
infile.close()

