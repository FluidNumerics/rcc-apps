#!/bin/sh
#
#SBATCH -o openfoam-%j.log
#SBATCH -e openfoam-%j.log

gcc --version

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions


sed -i 's/@NRANKS@/${SLURM_NTASKS}/g' ./system/decomposeParDict
decomposePar

# Run interFoam
mpirun --map-by socket --bind-to core -np ${SLURM_NTASKS} interFoam -parallel
