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

yum update -y
yum install -y valgrind valgrind-devel

if [[ "$IMAGE_NAME" != "rcc-"* ]]; then
   yum install -y gcc gcc-c++ gcc-gfortran
   pip3 install google-cloud-storage

   ## Install spack (from FluidNumerics fork)
   git clone https://github.com/FluidNumerics/spack.git ${INSTALL_ROOT}/spack
   
   echo "#!/bin/bash" > /etc/profile.d/z10_spack_environment.sh
   echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" >> /etc/profile.d/z10_spack_environment.sh
   echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/z10_spack_environment.sh
   source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
   
   # Find system compilers
   spack compiler find --scope site
fi

## For ensuring that Slurm paths are in default path ##
if [[ -f "/etc/profile.d/slurm.sh" ]]; then
	mv /etc/profile.d/slurm.sh /etc/profile.d/z11_slurm.sh
fi

## For ensuring that CUDA paths are in default path ##
if [[ -f "/etc/profile.d/cuda.sh" ]]; then
	mv /etc/profile.d/cuda.sh /etc/profile.d/z11_cuda.sh
fi

sed -i 's#@INSTALL_ROOT@#'"${INSTALL_ROOT}"'#g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
if [[ "$COMPILER" == *"intel"* ]]; then
  sed -i 's/@COMPILER@/intel/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
else
  sed -i 's/@COMPILER@/'"${COMPILER}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml
fi

sed -i 's/@ARCH@/'"${ARCH}"'/g' ${INSTALL_ROOT}/spack-pkg-env/spack.yaml

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

# Fluid Numerics Images (start with "fluid")
if [[ "$IMAGE_NAME" != "rcc-"* ]]; then
   spack install ${COMPILER}
   spack load ${COMPILER}
   spack compiler find --scope site
fi

spack env activate ${INSTALL_ROOT}/spack-pkg-env/
spack install --fail-fast --source
spack gc -y
spack env deactivate
spack env activate --sh -d ${INSTALL_ROOT}/spack-pkg-env/ >> /etc/profile.d/z10_spack_environment.sh 
