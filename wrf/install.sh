#!/bin/bash
#

SPACK_VERSION="v0.16.1"
GCC_VERSION="9.2.0"
OPENMPI_VERSION="4.0.5"
WRF_VERSION="4.2"
ARCH="x86_64"

######################################################################################################################
spack_setup() {
  yum install -y gcc gcc-c++ gcc-gfortran
  ## Install spack
  git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
  echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" > /etc/profile.d/spack.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

{
  echo "config:"
  echo "  install_tree: ${INSTALL_ROOT}/software"
} >> ${INSTALL_ROOT}/spack/etc/spack/config.yaml

  spack compiler find --scope site
  
  # Install lmod for module managament
  spack install lmod arch=$ARCH

  source $(spack location -i lmod)/lmod/lmod/init/bash
  echo "source $(spack location -i lmod)/lmod/lmod/init/bash" >> /etc/profile.d/spack.sh
  echo "source \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh
  echo "export LMOD_AUTO_SWAP=yes" >> /etc/profile.d/spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-x86_64" >> /etc/profile.d/spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-haswell" >> /etc/profile.d/spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-broadwell" >> /etc/profile.d/spack.sh
  echo "module unuse /usr/share/modulefiles" >> /etc/profile.d/spack.sh
  echo "module unuse /etc/modulefiles" >> /etc/profile.d/spack.sh
  echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-x86_64/Core" >> /etc/profile.d/spack.sh
}

lmod_setup() {
# Set up modules.yaml
cat > ${INSTALL_ROOT}/spack/etc/spack/modules.yaml << EOL
modules:
  enable::
    - lmod
  lmod:
    core_compilers:
      - 'gcc@4.8.5'
    hierarchy:
      - mpi
    whitelist:
      - gcc
    blacklist:
      - '%gcc@4.8.5'
    hash_length: 0
    all:
      environment:
        set:
          '{name}_ROOT': '{prefix}'
    projections:
      all:          '{name}/{version}'

EOL
  spack module lmod refresh --delete-tree -y
}
######################################################################################################################

spack_setup

# Switch to newer compiler
spack external find --scope site 
spack install gcc@${GCC_VERSION}
spack load gcc@${GCC_VERSION}
spack compiler find --scope site

# Spack is often unable to find slurm
{
  echo "  slurm:"
  echo "    externals:"
  echo "    - spec: slurm@20-11"
  echo "      prefix: ${SLURM_ROOT}"
} >> ${INSTALL_ROOT}/spack/etc/spack/packages.yaml


# Install WRF
spack install --source --fail-fast -y wrf@${WRF_VERSION} % gcc@${GCC_VERSION} target=${ARCH} \
	                      ^openmpi@${OPENMPI_VERSION}+cxx+cxx_exceptions+legacylaunchers+memchecker+pmi+static+vt+wrapper-rpath fabrics=auto schedulers=slurm target=${ARCH} \
			      ^cmake % gcc@4.8.5 target=${ARCH}

# Garbage collect
spack gc -y

# Install benchmark data
mkdir -p ${INSTALL_ROOT}/share/conus-2.5km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-2.5km/* ${INSTALL_ROOT}/share/conus-2.5km/
mkdir -p ${INSTALL_ROOT}/share/conus-12km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-12km/* ${INSTALL_ROOT}/share/conus-12km/

lmod_setup


# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  WRF-GCP VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/hpc-apps-gcp/wrf

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

. ${INSTALL_ROOT}/share/spack.sh
module load gcc/9.2.0
module load openmpi
module load hdf5 netcdf-c netcdf-fortran wrf

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

. ${INSTALL_ROOT}/share/spack.sh
module load gcc/9.2.0
module load openmpi
module load hdf5 netcdf-c netcdf-fortran wrf

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

module load gcc/9.2.0
module load openmpi
module load hdf5 netcdf-c netcdf-fortran wrf

mkdir -p \${WORK_PATH}
cd \${WORK_PATH}
ln -s \${INSTALL_ROOT}/share/conus-12km/* .
ln -s \$(spack location -i wrf)/run/* .

mpirun \$MPI_FLAGS ./wrf.exe
EOL

# Copy profile.d/spack.sh to /apps (assuming /apps is always NFS mounted)
cp /etc/profile.d/spack.sh ${INSTALL_ROOT}/share/spack.sh

cat > /apps/share/doc << EOL

# Notices

* The WRF software is based in part on the work of the Independent JPEG Group.

# Getting Started

This short tutorial will show you how to run WRF on a single VM without a job scheduler.

1. Load the necessary modules into your path
    module load gcc && module load openmpi
    module load hdf5 netcdf-c netcdf-fortran wrf

2. Create a directory for the CONUS 12km benchmark
    mkdir benchmark && cd benchmark

3. Link the CONUS 12km benchmark input decks to your new directory
    ln -s /opt/share/conus-12km/* ./
    ln -s \$(spack location -i wrf)/run/* ./

4. Run the job with 16 ranks (assuming you have an instance with at least 16 vCPU.
    mpirun -np 16 ./wrf.exe

To run on multiple virtual machines, you can :
* [Use a hostfile.](https://www.open-mpi.org/faq/?category=running#mpirun-hostfile)
* Provide an NFS or Lustre File System that hosts a common work directory across virtual machines. 

EOL
