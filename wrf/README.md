# WRF 
Copyright 2021 Fluid Numerics LLC

Maintainers: @schoonovernumerics

## Getting Started

You can use this repository to get started with your on VM image bakery on Google Cloud. This will allow you to customize the WRF installation to meet your preferences. 


Alternatively, you can use the `projects/hpc-apps/global/images/wrf-gcp-slurm-gcp-centos7-latest` VM image. This image is a free, use-at-your-own-risk image publicly offered by Fluid Numerics that is based on the latest `wrf-*` tag on this repository. The [slurm-gcp terraform deployment](./tf/slurm) will show you how to quickly get started with this VM image.

Fluid Numerics also offers a supported and quality controlled VM image `projects/hpc-apps/global/images/wrf-gcp-v1`. You can deploy from the [Google Cloud Marketplace](https://console.cloud.google.com/marketplace/fluid-cluster-ops/wrf-gcp) or using one of the supported terraform solutions : 
* [Supported slurm-gcp deployment](./tf/supported/slurm)
* [Supported GCE cluster deployment](./tf/supported/gce-cluster)


## How to use this image
This image installs WRF via spack into the `/opt` directory by default. lmod modules are used to allow WRF to be called into your path. When using this image, we recommend the following workflow

```
# Load WRF into your path
module load gcc
module load openmpi
module load hdf5 netcdf-c netcdf-fortran wrf

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
