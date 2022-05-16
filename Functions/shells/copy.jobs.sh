## Script for moving the data_in into data_out

## Input
user=$1

## Setting the paths
FROMUSER="${user}@awoonga.qriscloud.org.au"
FROMPATH="/30days/${user}/"
DATAOUT="/Volumes/CharacterCorrelation/CharacterCorrelationNew/Data_out/"
JOBSOUT="/Users/TGuillerme/Projects/CharactersCorrelation/Cluster/Bayesian/Jobs_out/"

## Downloading the jobs out
scp ${FROMUSER}:${FROMPATH}/CharSim/*.o* ${JOBSOUT}

## Getting the chain name
for file in ${JOBSOUT}*.o*
do
    chaintmp=$(echo ${file} | sed 's/.mbcmd.o[0-9]*//')
    chain=$(echo ${chaintmp} | sed 's/\/Users\/TGuillerme\/Projects\/CharactersCorrelation\/Cluster\/Bayesian\/Jobs_out\///')
    ## Copying the files
    echo ${chain}
    scp ${FROMUSER}:${FROMPATH}${chain}* ${DATAOUT}
done

## Cleaning
#for f in *.con.tre ; do chain=$(basename $f .con.tre); echo $chain ; srm ${chain}* ; echo " cleaned" ; done


# scp Users/TGuillerme/Projects/CharactersCorrelation/Cluster/Bayesian/Jobs_out/Done/75t_1000c_0111_rand uqapasto@awoonga.qriscloud.org.au:/home/uqapasto/CharSim/