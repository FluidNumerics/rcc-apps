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

yum update -y || ( export DEBIAN_FRONTEND=noninteractive && apt-get update -y )
yum install -y valgrind valgrind-devel || echo "Not on CentOS system"

if [[ "$IMAGE_NAME" != "rcc-"* ]]; then
   yum install -y gcc gcc-c++ gcc-gfortran || apt-get install -y build-essential
   pip3 install google-cloud-storage

   ## Install spack (from FluidNumerics fork)
   git clone https://github.com/FluidNumerics/spack.git ${INSTALL_ROOT}/spack
   
   echo "#!/bin/bash" > /etc/profile.d/z10_spack_environment.sh
   echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" >> /etc/profile.d/z10_spack_environment.sh
   echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/z10_spack_environment.sh
   source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
   
   # Find system compilers
   spack compiler find --scope site
   spack config add "config:install_tree:padded_length:128"
fi

## For ensuring that Slurm paths are in default path ##
if [[ -f "/etc/profile.d/slurm.sh" ]]; then
	mv /etc/profile.d/slurm.sh /etc/profile.d/z11_slurm.sh
fi

## For ensuring that CUDA paths are in default path ##
if [[ -f "/etc/profile.d/cuda.sh" ]]; then
	mv /etc/profile.d/cuda.sh /etc/profile.d/z11_cuda.sh
fi

# Set up the installation root for spack view
sed -i 's#@INSTALL_ROOT@#'"${INSTALL_ROOT}"'#g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml

# Set up the preferred compiler for all packages
if [[ "$COMPILER" == *"intel"* ]]; then
  sed -i 's/@COMPILER@/intel/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
else
  sed -i 's/@COMPILER@/'"${COMPILER}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
fi

# Set the target architecture for all packages
sed -i 's/@ARCH@/'"${ARCH}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml


source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

# Research Computing Cloud Images (start with "rcc")
if [[ "$IMAGE_NAME" != "rcc-"* ]]; then
   spack install ${COMPILER}
   spack load ${COMPILER}
   spack compiler find --scope site
fi


# Install packages specified in the spack environment
cat ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
spack env activate -d ${INSTALL_ROOT}/spack-pkg-env/
spack install --fail-fast --source
spack gc -y
spack env deactivate
spack env activate --sh -d ${INSTALL_ROOT}/spack-pkg-env/ >> /etc/profile.d/z10_spack_environment.sh 
