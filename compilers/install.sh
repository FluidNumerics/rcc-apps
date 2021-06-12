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

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
# Install lmod for module management
spack install lmod

# Install "after-market" compilers
spack install gcc@9.3.0
spack install intel-oneapi-compilers@2021.2.0

spack load gcc@9.3.0 && spack compiler find --scope site && spack unload gcc@9.3.0
spack load intel-oneapi-compilers@2021.2.0 && spack compiler find --scope site && spack unload intel-oneapi-compilers@2021.2.0

# Install openmpi compilers
spack install openmpi % gcc@9.3.0
spack install openmpi % intel@2021.2.0

# Create a GPG key for signing builds
mkdir -p ${INSTALL_ROOT}/share
spack gpg init
spack gpg create ${IMAGE_NAME}_gpg ${GPG_EMAIL}

# Create the buildcache for the base compilers and mpi flavors
for s in $(spack find --no-groups -L | cut -f 1 -d ' ' ); do
 spack buildcache create -a -f --rebuild-index -k ${IMAGE_NAME}_gpg -m ${IMAGE_NAME}_buildcache "/$s"
done

spack module lmod refresh --delete-tree -y

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
