#!/bin/bash
#
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#


#==============================================================================
# Set pointers to GROMACS and CUDA
#==============================================================================
source $(spack location -i gromacs)/bin/GMXRC
#module add cuda60/toolkit/6.0.37
export MDRUN="gmx mdrun"

#==============================================================================
# Set number of cores for the node and nranks to test
# (nthreads will then be selected automatically)
#==============================================================================
# 8-core machine with a single GPU
CORES=8
NRANKS=1
NGPU_PER_HOST=1
DLB="no"

#==============================================================================
# Where is the benchmark MD system
#==============================================================================
TPRDIR="/apps/share/gromacs"
TPRMEM="benchMEM.tpr"
STEPSMEM=5000   # Total steps to perform for each benchmark
RESETMEM=5000   # Reset mdrun time step counters after this time step number

#==============================================================================
# Do or do not restrict mdrun to use only certain GPUs:
#==============================================================================
USEGPUIDS="01234567"  # only GPU id's from this list will be used


#==============================================================================
# Helper function to exit the whole script as soon as something goes wrong
#==============================================================================
function func.testquit
{
    if [ "$1" = "0" ] ; then
        echo "OK"
    else
        echo "ERROR: exit code of the last command was $1. Exiting."
        exit
    fi
}
#==============================================================================


#==============================================================================
# From the number of GPUs per node and the number of PP ranks
# determine an appropriate value for mdrun's "-gpu_id" string.
#
# GPUs will be assigned to PP ranks in order, from the lower to
# the higher IDs, so that each GPU gets approximately the same
# number of PP ranks. Here is an example of how 5 PP ranks would
# be mapped to 2 GPUs:
#            +-----+-----+-----+-----+-----+
# PP ranks:  |  0  |  1  |  2  |  3  |  4  |
#            +-----+-----+-----+-----+-----+
# GPUs:      |  0  |  0  |  0  |  1  |  1  |
#            +-----+-----+-----+-----+-----+
#
# Will consecutively use GPU IDs from the list passed to this
# function as the third argument.
#
func.getGpuString ( )
{
    if [ $# -ne 3 ]; then 
        echo "ERROR: func.getGpuString needs #GPUs as 1st, #MPI as 2nd, and"
        echo "       a string with allowed GPU IDs as 3rd argument (all per node)!" >&2
        echo "       It got: '$@'" >&2
        exit 333
    fi

    # number of GPUs per node:
    local NGPU=$1
    # number of PP ranks per node:
    local N_PP=$2
    # string with the allowed GPU IDs to use:
    local ALLOWED=$3

    local currGPU=0
    local nextGPU=1
    local iPP
    # loop over all PP ranks on a node:
    for ((iPP=0; iPP < $N_PP; iPP++)); do
        local currGpuId=${ALLOWED:$currGPU:1} # single char starting at pos $currGPU
        local nextGpuId=${ALLOWED:$nextGPU:1} # single char starting at pos $nextGPU

        # append this GPU's ID to the GPU string:
        local GPUSTRING=${GPUSTRING}${currGpuId}

        # check which GPU ID the _next_ MPI rank should use:
        local NUM=$( echo "($iPP + 1) * $NGPU / $N_PP" | bc -l )
        local COND=$( echo "$NUM >= $nextGPU" | bc )
        if [ "$COND" -eq "1" ] ; then
            ((currGPU++))
            ((nextGPU++))
        fi
    done
    
    # return the constructed string:
    echo "$GPUSTRING"
}
#==============================================================================



#==============================================================================
# Do the benchmarks!
#==============================================================================

DIR=$( pwd )
NTOMP=$( echo "$CORES / $NRANKS" | bc )
GPUSTR=$( func.getGpuString $NGPU_PER_HOST $NRANKS $USEGPUIDS )
RUN=01_ntmpi${NRANKS}_ntomp${NTOMP}_dlb${DLB}

mkdir "$DIR"/run$RUN
func.testquit $?

cd "$DIR"/run$RUN
func.testquit $?
mkdir MEM
func.testquit $?
cd MEM
func.testquit $?
export GMX_NSTLIST=40
$MDRUN -ntmpi $NRANKS -ntomp $NTOMP -npme 0 -s "$TPRDIR/$TPRMEM" -cpt 1440 -nsteps $STEPSMEM -resetstep $RESETMEM -v -noconfout -nb gpu -dlb $DLB -gpu_id $GPUSTR
func.testquit $?
