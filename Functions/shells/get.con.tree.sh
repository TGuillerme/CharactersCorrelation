## Script for getting the consensus trees from the archives
PATH_OUT="/Users/TGuillerme/Projects/CharactersCorrelation/Data/Bayesian/Consensus_trees/"

for folder in *.cx1b
do
    ## Get the chain name
    chain_name=$(echo ${folder} | sed 's/\/Volumes\/LACIE\ SHARE\/CharacterCorrelationData_tmp\/Done\///g' | sed 's/_[0-9][0-9][0-9][0-9][0-9][0-9][0-9].cx1b//g')
    
    echo ${chain_name}
    echo "Copying trees:"
    cp ${folder}/${chain_name}_norm.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_maxi.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_mini.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_rand.con.tre ${PATH_OUT} ; printf "."
    echo "Done"

done



## Script for getting the consensus trees from the archives
PATH_OUT="/Users/TGuillerme/Projects/CharactersCorrelation/Bayesian/Data/Consensus_trees/"

for folder in *.cx1b
do
    ## Get the chain name
    chain_name=$(echo ${folder} | sed 's/\/Volumes\/LACIE\ SHARE\/CharacterCorrelationData_tmp\/Done\///g' | sed 's/_[0-9][0-9][0-9][0-9][0-9][0-9][0-9].cx1b//g')
    
    echo ${chain_name}
    echo "Copying trees:"
    cp ${folder}/${chain_name}_norm.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_maxi.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_mini.con.tre ${PATH_OUT} ; printf "."
    cp ${folder}/${chain_name}_rand.con.tre ${PATH_OUT} ; printf "."
    echo "Done"

done