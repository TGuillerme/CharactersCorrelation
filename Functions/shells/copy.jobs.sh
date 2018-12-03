## Script for moving the data_in into data_out

## Input
user=$1

## Setting the paths
FROMUSER="${user}@awoonga.qriscloud.org.au"
FROMPATH="/home/${user}/"
DATAOUT="/Volumes/CharacterCorrelation/CharacterCorrelationNew/Data_out"
JOBSOUT="/Users/TGuillerme/Projects/CharactersCorrelation/Cluster/Bayesian/Jobs_out"

## Downloading the jobs out
scp ${FROMUSER}:${FROMPATH}/CharSim/*.o* ${JOBSOUT}

## Getting the chain name
for file in ${JOBSOUT}*.o*
do
    chain=$(basename file .o*)
    ## Copying the files
    scp ${FROMUSER}:${FROMPATH}${chain}* ${DATAOUT}
done

## Cleaning
#for f in *.con.tre ; do chain=$(basename $f .con.tre); echo $chain ; srm ${chain}* ; echo " cleaned" ; done