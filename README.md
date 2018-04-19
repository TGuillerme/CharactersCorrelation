# Influence of different modes of morphological character correlation on phylogenetic tree inference
Author(s): [Thomas Guillerme](mailto:guillert@tcd.ie) and [Martin Brazeau](mailto:m.brazeau@imperial.ac.uk)

This repository contains all the code and data used in the manuscript [Link to final published pdf will be here]().

<!-- To cite the paper:  -->
<!-- > Thomas Guillerme \& Martin Brazeau. 2018. Influence of different modes of morphological character correlation on phylogenetic tree inference -->

<!-- To cite this repo:  -->
<!-- > Thomas Guillerme \& Martin Brazeau. 2018. Influence of different modes of morphological character correlation on phylogenetic tree inference -->

# Data

This article was based entirely on simulated data.
Below are the procedures to repeat the data simulation.
All the simulated data used in the article is archive on [Figshare](https://figshare.com/s/7a8fde8eaa39a3d3cf56) (see below).

## Simulating the data

The data simulation procedure is detailed in the paper and based on functions from the [`dispRity` package](https://github.com/TGuillerme/dispRity).
A tutorial to generate the "normal" matrix and modify it into the "minimised", "maximised" and "randomised" one is available [here in Rmd](https://github.com/TGuillerme/CharactersCorrelation/blob/master/Analysis/Character_difference/02-Modifying_matrices.Rmd) or [here in html](https://rawgit.com/TGuillerme/CharactersCorrelation/master/Analysis/Character_difference/02-Modifying_matrices.html).

## Running the simulations

The simulations were ran on the Imperial College High Performance Computing clusters (2-3GHz clock rate).
A tutorial for running the tree inferences specific to this cluster is available [here in Rmd](https://github.com/TGuillerme/CharactersCorrelation/blob/master/Analysis/Cluster/ClusterJobs.Rmd) or [here in html](https://rawgit.com/TGuillerme/CharactersCorrelation/master/Analysis/Cluster/ClusterJobs.html).

The script for generating the cluster jobs can be run using the [`set.runs.sh`](https://github.com/TGuillerme/CharactersCorrelation/blob/master/Functions/shells/set.runs.sh) script.
For example, use:

```
sh set.runs.sh 25t_100c_0001 MrBayes 8
```

For generating the MrBayes script for the 25t_100c_0001 chain (the first simulation for 25 taxa and 100 chains) for a 8 CPU node.

## Comparing the trees

The trees where compared using the [TreeCmp javascript](https://github.com/TGuillerme/CharactersCorrelation/blob/master/Functions/) from [Bogdanowicz et al 2012](http://journals.sagepub.com/doi/abs/10.4137/EBO.S9657).
The script used for running the comparisons was [`CC_TreeCmp.sh`](https://github.com/TGuillerme/CharactersCorrelation/blob/master/Functions/shells/CC_TreeCmp.sh).
For example, use:

```
sh CC_TreeCmp -c 25t_100c_0001 -r 1
```

For comparing the minimised, maximised and randomised tree from the chain 25t_100c_0001 to the normal tree.

## Archived data

The data used for the subsequent analysis is available on [Figshare](https://figshare.com/s/7a8fde8eaa39a3d3cf56).
The folder contains:

 * `Matrices` containing all 1260 matrices for all number of taxa (25, 75, 150), all numbers of characters (100, 350, 1000) and all modifications (normal, minimised, maximised, randomised) replicated 35 times each. This folder also contains the "true" trees used to generate the matrices.
 * `Trees/` containing the consensus trees:
    * In `Bayesian/` for the Bayesian inference trees.
    * In `Parsimony/` for the maximum parsimony trees.
    Both contains the trees per number of taxa and characters (e.g. `25t_100c` for 25 taxa and 100 characters)
 * `Comparisons/` containing the tree comparison scores:
    Containing again both `Bayesian/` and `Parsimony/` folders with their subfolders per taxa and characters for the comparisons to the normal tree (e.g. `25t_100c_cmp_norm`) or to the randomised tree (e.g. `25t_100c_cmp_rand`).

## Analyses

## Other folders

## Checkpoint for reproducibility
