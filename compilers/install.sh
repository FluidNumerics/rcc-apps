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
  yum install -y gcc gcc-c++ gcc-gfortran
  ## Install spack
  git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
  echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" > /etc/profile.d/spack.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/spack.sh
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
  spack compiler find --scope site
}

######################################################################################################################

spack_setup

# Add locally installed packages that are already available
export PATH=$PATH:/usr/local/cuda
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64

spack env activate /apps/spack-env/
spack install
spack module lmod refresh --delete-tree -y

# Create the buildcache
for s in $(spack find --no-groups -L | cut -f 1 -d ' ' ); do
  spack buildcache create -d ${BUILDCACHE} -a -u --only package "/$s"
done

despacktivate

spack env activate --sh -d /apps/spack-env >> /etc/profile.d/z10_spack_environment.sh
echo "source $(spack location -i lmod)/lmod/lmod/init/bash" >> /etc/profile.d/z10_spack_environment.sh
echo "export LMOD_AUTO_SWAP=yes" >> /etc/profile.d/z10_spack_environment.sh
echo "module unuse /usr/share/modulefiles" >> /etc/profile.d/z10_spack_environment.sh
echo "module unuse /etc/modulefiles" >> /etc/profile.d/z10_spack_environment.sh
echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-${ARCH}/Core" >> /etc/profile.d/z10_spack_environment.sh

gsutil cp -r ${BUILDCACHE} ${BUCKET}

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
