#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #

# Set any package variables here
SPACK_VERSION="develop"
BUILDCACHE="/tmp/gcp-spack-cache/${IMAGE_NAME}"
###


######################################################################################################################
spack_setup() {
  yum install -y gcc gcc-c++ gcc-gfortran patch
  ## Install spack
  # TO DO : Once  merged into main branch, bring back spack/spack repo
  #git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
  git clone https://github.com/FluidNumerics/spack.git ${INSTALL_ROOT}/spack

#  cp /tmp/gcs.py ${INSTALL_ROOT}/spack/lib/spack/spack/util
#  cd ${INSTALL_ROOT}
#  patch -t -p0 < /tmp/fetch_strategy_gcs.patch
#  patch -t -p0 < /tmp/web.patch

  echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" > /etc/profile.d/spack.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

  # Create a GPG key for signing builds
  mkdir -p ${INSTALL_ROOT}/share
  spack gpg init
  spack gpg create ${INSTALL_ROOT}/share/${IMAGE_NAME}_gpg ${GPG_EMAIL}

  # Add the mirror for this image
  spack mirror add ${IMAGE_NAME}_buildcache ${SPACK_CACHE_BUCKET}/${IMAGE_NAME}

  # Find system compilers
  spack compiler find --scope site

}

######################################################################################################################

spack_setup

# Enable the spack environment
spack env activate /apps/spack-env/
spack install
spack module lmod refresh --delete-tree -y

# Create a cache for the packages
spack buildcache create --rebuild-index -k ${INSTALL_ROOT}/share/${IMAGE_NAME}_gpg  -m ${IMAGE_NAME}_buildcache ...

despacktivate

# Add necesssary profile.d statements for lmod modules on VM image
spack env activate --sh -d /apps/spack-env >> /etc/profile.d/z10_spack_environment.sh
echo "source $(spack location -i lmod)/lmod/lmod/init/bash" >> /etc/profile.d/z10_spack_environment.sh
echo "export LMOD_AUTO_SWAP=yes" >> /etc/profile.d/z10_spack_environment.sh
echo "module unuse /usr/share/modulefiles" >> /etc/profile.d/z10_spack_environment.sh
echo "module unuse /etc/modulefiles" >> /etc/profile.d/z10_spack_environment.sh
echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-${ARCH}/Core" >> /etc/profile.d/z10_spack_environment.sh

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  HPC Apps VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/hpc-apps-gcp/spack

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
