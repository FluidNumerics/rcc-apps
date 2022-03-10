#!/bin/sh
#
# Source tutorial run functions

. $WM_PROJECT_DIR/bin/tools/RunFunctions

cd $WORKSPACE/bench/damBreakFine

# Run interFoam
mpirun --map-by socket --bind-to core -np ${SLURM_NTASKS} interFoam -parallel
