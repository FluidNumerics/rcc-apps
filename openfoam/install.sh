#!/bin/bash
#

# Enable GatewayPorts for Paraview reverse connections
sed -i 's/\#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config

# Update MOTD
cat > /etc/motd << EOL
=======================================================================  
  OpenFOAM-GCP VM Image
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
EOL

