#!/bin/bash
#

INSTALL_ROOT="/opt"
SPACK_VERSION="releases/latest"
GCC_VERSION="9.2.0"
OPENMPI_VERSION="4.0.5"
WRF_VERSION="4.2"

######################################################################################################################
spack_setup() {
  yum install -y gcc gcc-c++ gcc-gfortran
  ## Install spack
  git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
  echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" > /etc/profile.d/spack.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
  spack compiler find --scope site
  
  # Install lmod for module managament
  spack install lmod
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
spack install gcc@${GCC_VERSION}
spack load gcc@${GCC_VERSION}
spack compiler find

# Install WRF
spack install -y wrf@${WRF_VERSION} % gcc@${GCC_VERSION} ^openmpi@${OPENMPI_VERSION}

# Install benchmark data
mkdir -p ${INSTALL_ROOT}/share/conus-2.5km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-2.5km/* ${INSTALL_ROOT}/share/conus-2.5km/

lmod_setup

# Update MOTD
cat > /etc/motd << EOL
  WRF-GCP VM Image

  Copyright 2021 Fluid Numerics LLC

  https://github.com/FluidNumerics/hpc-apps-gcp

  To get started,
  
    module load gcc && module load openmpi
    module load hdf5 netcdf-c netcdf-fortran wrf

    mkdir benchmark && cd benchmark
    cp /opt/share/conus-2.5km/* ./
    ln -s $(spack location -i wrf)/run/* ./

    mpirun -np 60 ./wrf.exe


EOL
