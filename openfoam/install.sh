#!/bin/bash
#

# Install paraview
#wget --output-document /tmp/paraview.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.0-egl-MPI-Linux-Python3.9-x86_64.tar.gz"

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

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  CFD-GCP VM Image
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
EOL

