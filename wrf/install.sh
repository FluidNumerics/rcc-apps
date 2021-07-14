#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #


yum install -y valgrind valgrind-devel

sed -i 's#@INSTALL_ROOT@#'"${INSTALL_ROOT}"'#g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
if [[ "$COMPILER" == *"intel"* ]]; then
  sed -i 's/@COMPILER@/intel/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
else
  sed -i 's/@COMPILER@/'"${COMPILER}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
fi

sed -i 's/@ARCH@/'"${ARCH}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

if [[ "$IMAGE_NAME" != *"fluid-hpc"* ]]; then
   spack install ${COMPILER}
   spack load ${COMPILER}
   spack compiler find --scope site
fi

spack env activate ${INSTALL_ROOT}/spack-pkg-env/
spack install --fail-fast --source
spack gc -y
spack env deactivate
spack env activate --sh -d ${INSTALL_ROOT}/spack-pkg-env/ >> /etc/profile.d/z10_spack_environment.sh 

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

    https://github.com/FluidNumerics/hpc-apps-gcp

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
#SBATCH --partition=wrf
#SBATCH --ntasks=480
#SBATCH --ntasks-per-node=60
#SBATCH --mem-per-cpu=2g
#SBATCH --cpus-per-task=1
#SBATCH --account=default
#
# /////////////////////////////////////////////// #

WORK_PATH=\${HOME}/wrf-benchmark/
SRUN_FLAGS="-n \$SLURM_NTASKS --cpu-bind=threads" 

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
cp ${INSTALL_ROOT}/share/conus-2.5km/* .
ln -s \$(spack location -i wrf)/run/* .

srun \$MPI_FLAGS ./wrf.exe
EOL

cat > ${INSTALL_ROOT}/share/wrf-conus12.sh << EOL
#!/bin/bash
#SBATCH --partition=wrf
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=2g
#SBATCH --cpus-per-task=1
#SBATCH --account=default
#
# /////////////////////////////////////////////// #

WORK_PATH=\${HOME}/wrf-benchmark/
SRUN_FLAGS="-n \$SLURM_NTASKS --cpu-bind=threads" 

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
cp ${INSTALL_ROOT}/share/conus-12km/* .
ln -s \$(spack location -i wrf)/run/* .

srun \$MPI_FLAGS ./wrf.exe
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
