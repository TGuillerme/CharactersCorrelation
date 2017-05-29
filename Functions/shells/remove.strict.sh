## Script for removing the strict consensus tree from the paup con.tre files

## Input
chain=$1

## Get in the right dir
cd ${chain}/
echo "Running through ${chain}:"
## Loop through the con trees
for tree in ${chain}_*.con.tre
do
    strict_tree=$(grep -n "tree Strict" ${tree} | sed 's/:[[:space:]]tree Strict = .*;//g')
    sed ''"$strict_tree"'d' ${tree} > tmp
    tmp ${tree}
    printf "."
done
echo "Done"