#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #

sed -i "s/@INSTALL_ROOT@/${INSTALL_ROOT}/g" ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
sed -i "s/@COMPILER@/${COMPILER}/g" ${INSTALL_ROOT}/spack-pkg-env/spack.yaml

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

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  Gromacs-GCP VM Image
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

# Install benchmarks
mkdir -p ${INSTALL_ROOT}/share/gromacs
wget https://www.mpibpc.mpg.de/15101317/benchMEM.zip -P /tmp
wget https://www.mpibpc.mpg.de/15615646/benchPEP.zip -P /tmp
wget https://www.mpibpc.mpg.de/17600708/benchPEP-h.zip -P /tmp
wget https://www.mpibpc.mpg.de/15101328/benchRIB.zip -P /tmp

unzip /tmp/benchMEM.zip -d ${INSTALL_ROOT}/share/gromacs
unzip /tmp/benchPEP.zip -d ${INSTALL_ROOT}/share/gromacs
unzip /tmp/benchPEP-h.zip -d ${INSTALL_ROOT}/share/gromacs
unzip /tmp/benchRIB.zip -d ${INSTALL_ROOT}/share/gromacs

# Ensure that input deck permissions are readable by all
chmod 755 ${INSTALL_ROOT}/share/gromacs
chmod 644 ${INSTALL_ROOT}/share/gromacs/*
