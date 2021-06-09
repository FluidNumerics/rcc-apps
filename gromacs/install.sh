#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #

# Set any package variables here
SPACK_VERSION="develop"
GCC_VERSION="9.2.0"
OPENMPI_VERSION="4.0.5"
GMX_VERSION="2021.1"
ARCH="x86_64"
###


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
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
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

# Add locally installed packages that are already available
export PATH=$PATH:/usr/local/cuda
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
spack external find --scope site cuda
# Spack is often unable to find slurm
{
  echo "  slurm:"
  echo "    externals:"
  echo "    - spec: slurm@20-11"
  echo "      prefix: ${SLURM_ROOT}"
} >> ${INSTALL_ROOT}/spack/etc/spack/packages.yaml

# Install GCC compiler (newer version than system compiler)
spack install gcc@${GCC_VERSION}
spack load gcc@${GCC_VERSION}
spack compiler find --scope site

spack install --source --fail-fast gromacs@${GMX_VERSION}+cuda+mpi ^fftw+mpi ^openmpi@${OPENMPI_VERSION}+cuda+cxx+cxx_exceptions+legacylaunchers+memchecker+pmi+static+vt+wrapper-rpath fabrics=auto schedulers=slurm target=${ARCH}

spack gc -y

lmod_setup

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  Gromacs-GCP VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/hpc-apps-gcp/gromacs

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

# Install benchmarks
mkdir -p /apps/share/gromacs
wget https://www.mpibpc.mpg.de/15101317/benchMEM.zip -P /tmp
wget https://www.mpibpc.mpg.de/15615646/benchPEP.zip -P /tmp
wget https://www.mpibpc.mpg.de/17600708/benchPEP-h.zip -P /tmp
wget https://www.mpibpc.mpg.de/15101328/benchRIB.zip -P /tmp
wget https://www.mpibpc.mpg.de/15101343/dobenchs.zip -P /tmp
wget https://www.mpibpc.mpg.de/15101354/extract.zip -P /tmp

unzip /tmp/benchMEM.zip -d /apps/share/gromacs
unzip /tmp/benchPEP.zip -d /apps/share/gromacs
unzip /tmp/benchPEP-h.zip -d /apps/share/gromacs
unzip /tmp/benchRIB.zip -d /apps/share/gromacs
unzip /tmp/dobenchs.zip -d /apps/share/gromacs
unzip /tmp/extract.zip -d /apps/share/gromacs
