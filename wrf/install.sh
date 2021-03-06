#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #


# Install benchmark data
mkdir -p ${INSTALL_ROOT}/share/conus-2.5km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-2.5km/* ${INSTALL_ROOT}/share/conus-2.5km/
mkdir -p ${INSTALL_ROOT}/share/conus-12km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-12km/* ${INSTALL_ROOT}/share/conus-12km/

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  WRF-GCP VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/rcc-apps

  This solution contains free and open-source software 
  All applications installed can be listed using 

  spack find

  You can obtain the source code and licenses for any 
  installed application using the following command :

  ls \$(spack location -i pkg)/share/pkg/src

  replacing "pkg" with the name of the package.

=======================================================================  

  To get started, check out the included docs

    cat ${INSTALL_ROOT}/share/doc

EOL

# Add sample batch file to ${INSTALL_ROOT}/share
mkdir -p ${INSTALL_ROOT}/share
cat > ${INSTALL_ROOT}/share/wrf-conus2p5.sh << EOL
#!/bin/bash
#
# /////////////////////////////////////////////// #

WORK_PATH=\${HOME}/wrf-benchmark/
SRUN_FLAGS="-n \$SLURM_NTASKS --cpu-bind=threads" 

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
cp ${INSTALL_ROOT}/share/conus-2.5km/* .
ln -s \$(spack location -i wrf)/run/* .

srun \$SRUN_FLAGS ./wrf.exe
EOL

cat > ${INSTALL_ROOT}/share/wrf-conus12.sh << EOL
#!/bin/bash
#
# /////////////////////////////////////////////// #

WORK_PATH=\${HOME}/wrf-benchmark/
SRUN_FLAGS="-n \$SLURM_NTASKS --cpu-bind=threads" 

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
cp ${INSTALL_ROOT}/share/conus-12km/* .
ln -s \$(spack location -i wrf)/run/* .

srun \$SRUN_FLAGS ./wrf.exe
EOL

cat > ${INSTALL_ROOT}/share/wrf-conus12-gce.sh << EOL
#!/bin/bash
#
# This script runs the CONUS 12km benchmark for WRF v4
#
# By default, the number of MPI ranks is 16 and the path
# where the model output is stored in ~/wrf-benchmark
#
# Additionally, MPI ranks are bound to hardware threads.
#
# ////////////////////////////////////////////////////// #

: \${N_MPI_RANKS:=16}
: \${WORK_PATH:="\${HOME}/wrf-benchmark"}

MPI_FLAGS="-np \${N_MPI_RANKS} --map-by core --bind-to hwthread"

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
ln -s ${INSTALL_ROOT}/share/conus-12km/* .
ln -s \$(spack location -i wrf)/run/* .

mpirun \$MPI_FLAGS ./wrf.exe
EOL

mkdir -p ${INSTALL_ROOT}/share/
cat > ${INSTALL_ROOT}/share/doc << EOL

# Notices

* The WRF software is based in part on the work of the Independent JPEG Group.

# Getting Started

This short tutorial will show you how to run WRF on a single VM without a job scheduler.

1. Create a directory for the CONUS 12km benchmark
    mkdir benchmark && cd benchmark

2. Link the CONUS 12km benchmark input decks to your new directory
    ln -s /opt/share/conus-12km/* ./
    ln -s \$(spack location -i wrf)/run/* ./

3. Run the job with 16 ranks (assuming you have an instance with at least 16 vCPU.
    mpirun -np 16 ./wrf.exe

To run on multiple virtual machines, you can :
* [Use a hostfile.](https://www.open-mpi.org/faq/?category=running#mpirun-hostfile)
* Provide an NFS or Lustre File System that hosts a common work directory across virtual machines. 

EOL
