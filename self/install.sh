#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #


source /etc/profile.d/z10_spack_environment.sh

if [[ "$IMAGE_NAME" != "rcc-"* ]]; then
    # Install hipfort
    git clone https://github.com/ROCmSoftwarePlatform/hipfort.git /tmp/hipfort
    mkdir /tmp/hipfort/build
    cd /tmp/hipfort/build
    FC=$(which gfortran) cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm /tmp/hipfort
    make -j install
    echo "PATH=\${PATH}:/opt/rocm/bin" >> /etc/profile.d/z10_spack_environment.sh
fi

# SELF Serial-x86 build
git clone https://github.com/FluidNumerics/self.git /tmp/self
cd /tmp
BUILD=release \
SELF_PREFIX=/opt/self/serial-x86 \
FC=gfortran \
PREC=double \
make
rm -r /tmp/self

git clone https://github.com/FluidNumerics/self.git /tmp/self
cd /tmp
BUILD=release \
SELF_PREFIX=/opt/self/serial-x86-nvcc \
FC=hipfort \
HIPFORT_GPU=sm_70 \
PREC=double \
make
mv /tmp/self/src/ /opt/self/
rm -r /tmp/self


# TO DO : Add Modules for self/serial-x86 and self/serial-x86-nvcc

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  SELF VM Image
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
