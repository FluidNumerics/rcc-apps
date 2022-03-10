#!/bin/bash
#
# /////////////////////////////////////////////// #

mkdir -p $WORKSPACE/bench

cd $WORKSPACE/bench/

# Copy the compressible flow over NACA0012 aerofoil demo
cp -r ${FOAM_TUTORIALS}/compressible/rhoSimpleFoam/aerofoilNACA0012 ./

cd $WORKSPACE/bench/aerofoilNACA0012

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# Copy aerofoil surface from resources directory
cp $FOAM_TUTORIALS/resources/geometry/NACA0012.obj.gz constant/geometry/

runApplication blockMesh
runApplication transformPoints -scale "(1 0 1)"
runApplication extrudeMesh
