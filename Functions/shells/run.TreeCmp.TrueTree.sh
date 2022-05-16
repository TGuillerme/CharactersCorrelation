## Shell script for running the TreeCmp on the parsimony trees

## Copying the trees into the right folder
cp ~/Projects/CharactersCorrelation/Data/Trees_out/Single_trees/Parsimony/Consensus_trees/Done/25t*_norm.con.tre ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Parsimony/
cp ~/Projects/CharactersCorrelation/Data/Trees_out/Single_trees/Bayesian/Consensus_trees/Done/25t*_norm.con.tre ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Bayesian/

## Going to the right folder
cd ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Parsimony/

## Launching the comparisons
sh CC_TreeCmp_wrapper.sh

## Cleaning
rm ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Parsimony/25t*_norm.con.tre

## Going to the right folder
cd ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Bayesian/

## Launching the comparisons
sh CC_TreeCmp_wrapper.sh

## Cleaning
rm ~/Projects/CharactersCorrelation/Data/Trees_out/True_trees/Bayesian/25t*_norm.con.tre