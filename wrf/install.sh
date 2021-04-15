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
  echo "export SPACK_ROOT=/apps/spack" > /etc/profile.d/setup_spack.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/setup_spack.sh
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
  spack compiler find --scope site
  
  # Install lmod for module managament
  spack install lmod
  source $(spack location -i lmod)/lmod/lmod/init/bash
  source /apps/spack/share/spack/setup-env.sh
  echo "source $(spack location -i lmod)/lmod/lmod/init/bash" >> /etc/profile.d/setup_spack.sh
  echo "source \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/setup_spack.sh
  echo "export LMOD_AUTO_SWAP=yes" >> /etc/profile.d/setup_spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-x86_64" >> /etc/profile.d/setup_spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-haswell" >> /etc/profile.d/setup_spack.sh
  echo "module unuse ${INSTALL_ROOT}/spack/share/spack/modules/linux-centos7-broadwell" >> /etc/profile.d/setup_spack.sh
  echo "module unuse /usr/share/modulefiles" >> /etc/profile.d/setup_spack.sh
  echo "module unuse /etc/modulefiles" >> /etc/profile.d/setup_spack.sh
  echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-x86_64/Core" >> /etc/profile.d/setup_spack.sh
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

spack_setup()
# Switch to newer compiler
spack install gcc@${GCC_VERSION}
spack load gcc@${GCC_VERSION}
spack compiler find

# Install WRF
spack install -y wrf@${WRF_VERSION} % gcc@${GCC_VERSION} ^openmpi@${OPENMPI_VERSION}~atomics+cuda+cxx+cxx_exceptions+gpfs~java+legacylaunchers~lustre+memchecker+pmi~singularity~sqlite3+static~thread_multiple+vt+wrapper-rpath fabrics=auto schedulers=slurm

# Install benchmark data
mkdir -p ${INSTALL_ROOT}/share/conus-2.5km
gsutil -u ${PROJECT_ID} cp gs://wrf-gcp-benchmark-data/benchmark/conus-2.5km/* ${INSTALL_ROOT}/share/conus-2.5km/

lmod_setup()
