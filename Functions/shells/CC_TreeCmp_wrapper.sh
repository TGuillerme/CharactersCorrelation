## Wrapper script for CC_TreeCmp

## Input the folder name
folder=$1

## Move files to the current directory
mv ${folder}/* ./

## Loop through each replicate of the chain
for norm in *_norm.con.tre
do
    chain=$(basename $norm _norm.con.tre)
    echo ${chain}
    ## Run the tree comparisons
    sh CC_TreeCmp.sh -c ${chain} -r 4
    sh CC_TreeCmp.sh -c ${chain} -r 1
done

## Check if the right Done folder exists
if ls Done/ | grep ${folder} > /dev/null
then
    silent="silent"
else 
    mkdir Done/${folder}
fi

## Move the files in Done folder
mv ${folder}*.con.tre Done/${folder}/
mv ${folder}*_truetree.nex Done/${folder}/