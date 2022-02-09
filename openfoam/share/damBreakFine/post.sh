#!/bin/sh
#
#SBATCH -o openfoam-%j.log
#SBATCH -e openfoam-%j.log

# Post process to stitch together model output from each MPI rank
reconstructPar

# Touch a .foam file to be able to load this case in paraview
touch dambreak.foam
