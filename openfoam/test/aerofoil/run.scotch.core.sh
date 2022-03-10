#!/bin/sh
#
# Source tutorial run functions

. $WM_PROJECT_DIR/bin/tools/RunFunctions

cd $WORKSPACE/bench/aerofoilNACA0012

cat > ./system/decomposeParDict <<EOL
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
numberOfSubdomains $SLURM_NTASKS;
method          scotch;
 
EOL

decomposePar

# Run rhoSimpleFoam
mpirun --map-by socket --bind-to core -np ${SLURM_NTASKS} rhoSimpleFoam -parallel
