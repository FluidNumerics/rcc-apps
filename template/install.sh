#!/bin/bash
#
#
# Maintainers : @your-github-handle-here
#
# //////////////////////////////////////////////////////////////// #

# Set any package variables here
INSTALL_ROOT="/opt"
SPACK_VERSION="releases/latest"
#GCC_VERSION="9.2.0"
#OPENMPI_VERSION="4.0.5"
###


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
######################################################################################################################

spack_setup()

## Package Installation Instructions ##

#spack install gcc@${GCC_VERSION}
#spack load gcc@${GCC_VERSION}
#spack compiler find
#
