#!/bin/bash
#

SPACK_VERSION="releases/latest"
GCC_VERSION="9.2.0"
OPENMPI_VERSION="4.0.5"
OPENFOAM_VERSION="8"
PARAVIEW_VERSION="5.9.0"
ARCH="x86_64"

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
spack compiler find --scope site

spack external find --scope site 

# Spack is often unable to find slurm
{
  echo "  slurm:"
  echo "    externals:"
  echo "    - spec: slurm@20-11"
  echo "      prefix: ${SLURM_ROOT}"
} >> ${INSTALL_ROOT}/spack/etc/spack/packages.yaml

# Install OpenFOAM
spack install --fail-fast -y openfoam@${OPENFOAM_VERSION} % gcc@${GCC_VERSION} ^openmpi@${OPENMPI_VERSION}~atomics~cuda+cxx+cxx_exceptions~gpfs~java+legacylaunchers+lustre+memchecker+pmi~singularity~sqlite3+static~thread_multiple+vt+wrapper-rpath fabrics=auto schedulers=slurm ^cmake % gcc@4.8.5 target=${ARCH}

# Install Paraview
spack install --fail-fast -y paraview@${PARAVIEW_VERSION} % gcc@${GCC_VERSION} ^openmpi@${OPENMPI_VERSION}~atomics~cuda+cxx+cxx_exceptions~gpfs~java+legacylaunchers+lustre+memchecker+pmi~singularity~sqlite3+static~thread_multiple+vt+wrapper-rpath fabrics=auto schedulers=slurm ^cmake % gcc@4.8.5 target=${ARCH}


lmod_setup


# Update MOTD
cat > /etc/motd << EOL
  OpenFOAM VM Image

  Copyright 2021 Fluid Numerics LLC

  https://github.com/FluidNumerics/hpc-apps-gcp

  This offering is not approved or endorsed by OpenCFD Ltd,
  producer and distributor of the OpenFOAM software via www.openfoam.com,
  and owner of the OPENFOAM trademark.

  To get started,
  
    module load gcc && module load openmpi
    module load openfoam paraview

EOL

# Copy profile.d/spack.sh to /apps (assuming /apps is always NFS mounted)
cp /etc/profile.d/spack.sh /apps/share/spack.sh
