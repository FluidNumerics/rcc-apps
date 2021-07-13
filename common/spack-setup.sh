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


######################################################################################################################
if [[ "$IMAGE_NAME" != *"fluid-hpc"* ]]; then
   yum install -y gcc gcc-c++ gcc-gfortran
   pip3 install google-cloud-storage
   ## Install spack
   # TO DO : Once  merged into main branch, bring back spack/spack repo
   #git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
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
	mv /etc/profile.d/cuda.sh /etc/profile.d/z12_cuda.sh
fi
