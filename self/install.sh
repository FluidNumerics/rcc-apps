#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #


source /etc/profile.d/z10_spack_environment.sh

# Install hipfort
git clone https://github.com/ROCmSoftwarePlatform/hipfort.git /tmp/hipfort
mkdir /tmp/hipfort/build
cd /tmp/hipfort/build
FC=$(which gfortran) cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm /tmp/hipfort
make -j install
echo "PATH=\${PATH}:/opt/rocm/bin" >> /etc/profile.d/z10_spack_environment.sh


# FEQParse
git clone https://github.com/FluidNumerics/feq-parse.git /tmp/extern/feq-parse
mkdir -p /tmp/extern/feq-parse/build
cd /tmp/extern/feq-parse/build
cmake -DCMAKE_INSTALL_PREFIX="/opt/feqparse" /tmp/extern/feq-parse
make && make install

# FLAP
git clone --recurse-submodules https://github.com/szaghi/FLAP.git /tmp/extern/FLAP
mkdir -p /tmp/extern/FLAP/build
cd /tmp/extern/FLAP/build 
FFLAGS=-cpp cmake -DCMAKE_INSTALL_PREFIX="/opt/FLAP" /tmp/extern/FLAP
make && make install


source /etc/profile.d/z10_spack_environment.sh
# SELF Serial-x86 build
git clone https://github.com/FluidNumerics/self.git /tmp/self
cd /tmp
BUILD=release \
SELF_PREFIX=/opt/self/serial-x86 \
FC=gfortran \
PREC=double \
make

git clone https://github.com/FluidNumerics/self.git /tmp/self
cd /tmp
BUILD=release \
SELF_PREFIX=/opt/self/serial-x86-nvcc \
FC=hipfort \
HIPFORT_GPU=sm_70 \
PREC=double \
make


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
