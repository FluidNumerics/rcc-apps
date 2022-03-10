#!/bin/bash
#
# /////////////////////////////////////////////// #

mkdir -p $WORKSPACE/bench

cp -r /opt/share/damBreakFine $WORKSPACE/bench

cd $WORKSPACE/bench/damBreakFine

# Copy in initial conditions and physical constants dictionaries
cp -r $FOAM_TUTORIALS/multiphase/interFoam/laminar/damBreak/damBreak/0 .
cp -r $FOAM_TUTORIALS/multiphase/interFoam/laminar/damBreak/damBreak/constant .

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# Remove any existing log files and the original volume fraction intial conditions
rm log.*
rm 0/alpha.water

# Generate the mesh
runApplication blockMesh

# Generate the initial condition for the volume fraction
runApplication setFields
