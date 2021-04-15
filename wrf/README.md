# WRF 
Copyright 2021 Fluid Numerics LLC

Maintainers: @schoonovernumerics

## How to use this image
This image installs WRF via spack into the `/opt` directory by default. lmod modules are used to allow WRF to be called into your path. When using this image, we recommend the following workflow

```
# Load WRF into your path
module load gcc
module load openmpi
module load wrf

# Create a WRF test case
export CASE_DIR=${HOME}/benchmark
mkdir $CASE_DIR

# Copy input decks
#  >  Input decks must include namelist.input, wrfdby_d01, and wrfinput_d01
cp /opt/share/conus-2.5km/* ${CASE_DIR}/

# Symbolic link in WRF executable
ln -s $(spack external find -i wrf)/run/* ${CASE_DIR}/

# Navigate to the test case directory and launch wrf
mpirun -np ${SLURM_NTASKS} --bind-to core --map-by core ./wrf.exe

```
This example shows how to run the CONUS 2.5km benchmark in your `${HOME}/benchmark` directory. Note that the CONUS 2.5km input decks are included with this VM image.
