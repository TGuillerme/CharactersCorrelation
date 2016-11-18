#!/bin/sh

##########################
#Shell script for building up the MrBayes consensus trees
##########################
#SYNTAX:
#sh con.tree.sh <chain_name>
#with:
#<chain_name> the name of the chain containing the norm/mini/maxi trees
##########################
#----
#guillert(at)tcd.ie - 2016/11/18
##########################

## Step 1 - INPUT

## Input values
chain_name=$1

## Renaming the matrices
cp ${chain_name}_norm.nex ${chain_name}_norm
cp ${chain_name}_maxi.nex ${chain_name}_maxi
cp ${chain_name}_mini.nex ${chain_name}_mini

## Generating the template file for calculating the consensus tree in MrBayes
echo "set autoclose=yes nowarn=yes;
execute <CHAIN>;
sumt Relburnin=YES Burninfrac=0.25;" > contree.template

## Copying the commands to the matrices
cat contree.template | sed 's/<CHAIN>/'"${chain_name}"'_norm/g' > ${chain_name}_norm_contree.cmd
cat contree.template | sed 's/<CHAIN>/'"${chain_name}"'_maxi/g' > ${chain_name}_maxi_contree.cmd
cat contree.template | sed 's/<CHAIN>/'"${chain_name}"'_mini/g' > ${chain_name}_mini_contree.cmd

## Running the trees
echo "Generating the consensus tree:"
mb ${chain_name}_norm_contree.cmd > /dev/null
echo "."
mb ${chain_name}_maxi_contree.cmd > /dev/null
echo "."
mb ${chain_name}_mini_contree.cmd > /dev/null
echo "."
echo "Done"

## Cleaning the files
rm contree.template
rm ${chain_name}_norm
rm ${chain_name}_maxi
rm ${chain_name}_mini
rm ${chain_name}_norm_contree.cmd
rm ${chain_name}_maxi_contree.cmd
rm ${chain_name}_mini_contree.cmd
