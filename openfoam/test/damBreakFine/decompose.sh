#!/bin/sh
#
# Source tutorial run functions

. $WM_PROJECT_DIR/bin/tools/RunFunctions

cd $WORKSPACE/bench/damBreakFine

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
