#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  Gromacs-GCP VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/rcc-apps

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
wget https://www.mpinat.mpg.de/benchMEM -O /tmp/benchMEM.zip
wget https://www.mpinat.mpg.de/benchRIB -O /tmp/benchRIB.zip
wget https://www.mpinat.mpg.de/benchPEP -O /tmp/benchPEP.zip

unzip /tmp/benchMEM.zip -d ${INSTALL_ROOT}/share/gromacs
unzip /tmp/benchPEP.zip -d ${INSTALL_ROOT}/share/gromacs
unzip /tmp/benchRIB.zip -d ${INSTALL_ROOT}/share/gromacs

# Ensure that input deck permissions are readable by all
chmod 777 ${INSTALL_ROOT}/share
chmod 666 ${INSTALL_ROOT}/share/gromacs_bench.sh
chmod 777 ${INSTALL_ROOT}/share/gromacs
chmod 666 ${INSTALL_ROOT}/share/gromacs/*
