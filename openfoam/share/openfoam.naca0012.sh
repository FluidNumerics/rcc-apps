#!/bin/sh
#
#SBATCH -o openfoam-%j.log
#
#SBATCH -e openfoam-%j.log
#
# ////////////////////////////////////////// #

# Refresh the spack environment
# This is needed for mixing rcc-cfd image flavors
spack env deactivate
spack env activate -d /opt/spack-pkg-env

# Copy the compressible flow over NACA0012 aerofoil demo
cp -r ${FOAM_TUTORIALS}/compressible/rhoSimpleFoam/aerofoilNACA0012 ./

# Navigate into the aerofoil demo
cd aerofoilNACA0012

# Set up domain decomposition file
cat > ./system/decomposeParDict <<EOL
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
numberOfSubdomains ${SLURM_NTASKS};
method          scotch;
EOL

# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# Copy aerofoil surface from resources directory
cp $FOAM_TUTORIALS/resources/geometry/NACA0012.obj.gz constant/geometry/

runApplication blockMesh
runApplication transformPoints -scale "(1 0 1)"
runApplication extrudeMesh
decomposePar

# Run rhoSimpleFoam
mpirun -np ${SLURM_NTASKS} rhoSimpleFoam -parallel

# Post process to stitch together model output from each MPI rank
reconstructPar

# Touch a .foam file to be able to load this case in paraview
touch naca0012.foam
