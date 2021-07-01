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
yum install -y gcc gcc-c++ gcc-gfortran
pip3 install google-cloud-storage
## Install spack
# TO DO : Once  merged into main branch, bring back spack/spack repo
#git clone https://github.com/spack/spack.git --branch ${SPACK_VERSION} ${INSTALL_ROOT}/spack
git clone https://github.com/FluidNumerics/spack.git ${INSTALL_ROOT}/spack

echo "#!/bin/bash" > /etc/profile.d/z10_spack_environment.sh
echo "export SPACK_ROOT=${INSTALL_ROOT}/spack" >> /etc/profile.d/z10_spack_environment.sh
echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/z10_spack_environment.sh
echo "export LMOD_AUTO_SWAP=yes" >> /etc/profile.d/z10_spack_environment.sh
echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-x86_64/Core" >> /etc/profile.d/z10_spack_environment.sh

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh


# Add the mirror for this image
spack mirror add ${IMAGE_NAME}_buildcache ${SPACK_CACHE_BUCKET}/${IMAGE_NAME}

# Find system compilers
spack compiler find --scope site