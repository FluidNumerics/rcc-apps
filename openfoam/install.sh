#!/bin/bash
#

# Install paraview
wget --output-document /tmp/paraview.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.0-osmesa-MPI-Linux-Python3.9-x86_64.tar.gz"

mkdir /opt/paraview
tar -xvzf /tmp/paraview.tar.gz --directory /opt/paraview --strip-components 1

cat > /etc/profile.d/z11_paraview.sh <<EOL
#!/bin/bash

export PATH=\${PATH}:/opt/paraview/bin
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/paraview/lib

EOL

# Enable GatewayPorts for Paraview reverse connections
sed -i 's/\#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config

# Install Gmsh

GMSH_VERSION="4_6_0"

mkdir -p /opt/build
source /opt/rh/devtoolset-9/enable

# Install freetype
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz --directory-prefix=/opt/build
cd /opt/build
tar zxvf freetype-2.8.tar.gz
cd /opt/build/freetype-2.8
cp docs/GPLv2.TXT /opt/license/LICENSE.freetype
./configure --prefix=/opt/gmsh
make
make install


# Install OpenCASCADE
echo "OpenCASCADE is licensed under the GNU Lesser General Public License v2.1 : https://old.opencascade.com/content/licensing" > /opt/license/LICENSE.OpenCASCADE
curl -L -o /opt/build/occt.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V7_3_0;sf=tgz"
cd /opt/build
tar zxf occt.tgz
cd occt-V7_3_0
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_MODULE_Draw=0 \
      -DBUILD_MODULE_Visualization=0 \
      -DBUILD_MODULE_ApplicationFramework=0 \
      -DCMAKE_PREFIX_PATH=/opt/gmsh \
      -DCMAKE_INSTALL_PREFIX=/opt/gmsh ..
make
make install

# Install FLTK
wget http://fltk.org/pub/fltk/1.3.4/fltk-1.3.4-2-source.tar.gz --directory-prefix=/opt/build
cd /opt/build
tar zxvf fltk-1.3.4-2-source.tar.gz
cd fltk-1.3.4-2
./configure --prefix=/opt/gmsh
make
make install

# Install gmsh and a module file under opt
git clone http://gitlab.onelab.info/gmsh/gmsh.git /opt/build/gmsh
cd /opt/build/gmsh
mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH=/opt/gmsh -DCMAKE_INSTALL_PREFIX=/opt/gmsh -DENABLE_OPENMP=1 -DENABLE_BUILD_DYNAMIC=1 ..
make

cat > /etc/profile.d/z11_gmsh.sh <<EOL
#!/bin/bash

export PATH=\${PATH}:/opt/gmsh/bin

EOL


# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  CFD-GCP VM Image
  Copyright 2021 Fluid Numerics LLC

=======================================================================  

  Open source implementations of this solution can be found at

    https://github.com/FluidNumerics/rcc-opt

  This solution contains free and open-source software 
  All applications installed can be listed using 

  spack find

  You can obtain the source code and licenses for any 
  installed application using the following command :

  ls \$(spack location -i pkg)/share/pkg/src

  replacing "pkg" with the name of the package.

  This offering is not approved or endorsed by OpenCFD Limited, producer
  and distributor of the OpenFOAM® software via www.openfoam.com, and 
  owner of the OPENFOAM® and OpenCFD® trade marks.

=======================================================================  
EOL

