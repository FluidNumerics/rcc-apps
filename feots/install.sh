#!/bin/bash
#
#
# Maintainers : @schoonovernumerics
#
# //////////////////////////////////////////////////////////////// #


source /etc/profile.d/z10_spack_environment.sh 
spack load ${COMPILER} openmpi@4.0.2 % ${COMPILER}

ln -s $(spack location -i netcdf-fortran)/lib/* $(spack location -i netcdf-c)/lib/
ln -s $(spack location -i netcdf-fortran)/include/* $(spack location -i netcdf-c)/include/

# Install FEOTS #
git clone https://github.com/FluidNumerics/FEOTS.git /tmp/FEOTS
cd /tmp/FEOTS
autoreconf --install
FCFLAGS="-Ofast -g -pg -ffree-line-length-none" ./configure --enable-mpi --prefix=${INSTALL_ROOT}/feots
make
make install
# Add the examples to the install path
cp -r /tmp/FEOTS/examples ${INSTALL_ROOT}/feots

echo "#!/bin/bash" > /etc/profile.d/z11_feots.sh
echo "export PATH=\${PATH}:${INSTALL_ROOT}/feots/bin" >> /etc/profile.d/z11_feots.sh
echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${INSTALL_ROOT}/feots/lib" >> /etc/profile.d/z11_feots.sh
echo "export FEOTS_LIB=\"-L${INSTALL_ROOT}/feots/lib -lfeots\"" >> /etc/profile.d/z11_feots.sh
echo "export FEOTS_INCLUDE=\"-I${INSTALL_ROOT}/feots/include" >> /etc/profile.d/z11_feots.sh

# Add Argentine Basin input decks
mkdir -p ${INSTALL_ROOT}/feots-db
mkdir -p ${INSTALL_ROOT}/feots-db/argentine-basin
gsutil -m cp -r gs://feots-db/E3SMV0-HILAT-5DAVG ${INSTALL_ROOT}/feots-db
gsutil -m cp -r gs://feots-db/argentine_basin_regional_operators/* ${INSTALL_ROOT}/feots-db/argentine-basin/


mkdir -p ${INSTALL_ROOT}/share/argentine-basin
source /etc/profile.d/z11_feots.sh
cp ${INSTALL_ROOT}/feots/examples/zapiola/*.f90 \
   ${INSTALL_ROOT}/feots/examples/zapiola/Makefile \
   ${INSTALL_ROOT}/feots/examples/zapiola/runtime.params \
   ${INSTALL_ROOT}/share/argentine-basin/

mv /tmp/share/demo.sh ${INSTALL_ROOT}/share/argentine-basin/

cd ${INSTALL_ROOT}/share/argentine-basin
make



# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  FEOTS-GCP VM Image
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
