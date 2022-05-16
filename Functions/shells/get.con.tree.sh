## Get the chain prefix
chain_prefix=$1

## Script for getting the consensus trees from the archives
PATH_OUT="/Users/TGuillerme/Projects/CharactersCorrelation/Data/Trees_out/Consensus_trees/Bayesian"

for folder in ${chain_prefix}*
do
    ## Get the chain name
    chain_name=$(echo ${folder} | sed 's/\/Volumes\/CharacterCorrelation\/CharacterCorrelationNew\///g')
    
    list=$(ls ${PATH_OUT})
    if echo $list | grep -q ${chain_prefix}
    then
        silent="silent"
    else
        mkdir ${PATH_OUT}/${chain_prefix}
    fi

    echo ${chain_name}
    echo "Copying trees:"
    cp ${folder}/${chain_name}_norm.con.tre ${PATH_OUT}/${chain_prefix} ; printf "."
    cp ${folder}/${chain_name}_maxi.con.tre ${PATH_OUT}/${chain_prefix} ; printf "."
    cp ${folder}/${chain_name}_mini.con.tre ${PATH_OUT}/${chain_prefix} ; printf "."
    cp ${folder}/${chain_name}_rand.con.tre ${PATH_OUT}/${chain_prefix} ; printf "."
    
    ## Adding the true tree as well
    cp /Users/TGuillerme/Projects/CharactersCorrelation/Data/Simulations/Trees/${chain_name}_truetree.nex ${PATH_OUT}/${chain_prefix} ; printf "."
    
    ## Move the folder
    mv ${folder} Done/
    echo "Done"


done