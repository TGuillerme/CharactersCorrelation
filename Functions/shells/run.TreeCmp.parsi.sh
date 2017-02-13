## Shell script for running the TreeCmp on the parsimony trees

## Copying the trees into the right folder
cp ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.tre ~/Projects/CharactersCorrelation/Data/Trees_out/Single_trees/Parsimony/Consensus_trees/

## Moving the used trees to Done
mv ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.tre ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/Done/
mv ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.bs ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/Done/
mv ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.contre ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/Done/
mv ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.log ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/Done/
rm ~/Projects/CharactersCorrelation/Cluster/Parsimony/Done/*.paupjob

## Going to the right folder
cd ~/Projects/CharactersCorrelation/Data/Trees_out/Single_trees/Parsimony/Consensus_trees/

## Renaming them to .con.tree for consistency
for tree in *.tre
do
    prefix=$(basename $tree .tre)
    mv $tree ${prefix}.con.tre
done

## Launching the comparisons
sh CC_TreeCmp_wrapper.sh
