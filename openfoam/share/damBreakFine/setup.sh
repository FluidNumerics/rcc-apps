#!/bin/sh
#
#SBATCH -o openfoam-%j.log
#
#SBATCH -e openfoam-%j.log
#
#
gcc --version

cp -r $FOAM_TUTORIALS/multiphase/interFoam/laminar/damBreak/damBreak/0 .
cp -r $FOAM_TUTORIALS/multiphase/interFoam/laminar/damBreak/damBreak/constant .

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

rm log.*
rm 0/alpha.water

runApplication blockMesh
runApplication setFields
