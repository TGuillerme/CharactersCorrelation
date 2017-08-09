## Get the chain prefix
chain_prefix=$1

for chain in ${chain_prefix}_*_norm.contre
do
    chain=$(basename ${chain} _norm.contre)
    mkdir ${chain}
    mv ${chain}_norm.contre ${chain}_norm.con.tre
    mv ${chain}_mini.contre ${chain}_mini.con.tre
    mv ${chain}_maxi.contre ${chain}_maxi.con.tre
    mv ${chain}_rand.contre ${chain}_rand.con.tre
    mv ${chain}_* ${chain}/
done
