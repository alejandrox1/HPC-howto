#!/bin/bash

#SBATCH --exclusive           
#SBATCH -t 2-0               
#SBATCH -o slurm.%j.out

module load nwchem

n=$1

ibrun -np $n nwchem acetylene_restart.nw

