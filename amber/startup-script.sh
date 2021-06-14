#!/bin/bash


# Install GNU compilers and CMake
yum -y update
yum -y install tcsh make \
               gcc gcc-gfortran gcc-c++ \
               which flex bison patch bc \
               libXt-devel libXext-devel \
               perl perl-ExtUtils-MakeMaker util-linux wget \
               bzip2 bzip2-devel zlib-devel tar

# Cmake install from source (version 3.12 or greater is needed for Amber20)
wget https://cmake.org/files/v3.12/cmake-3.12.3.tar.gz
tar -xvzf cmake-3.12.3.tar.gz
cd cmake-3.12.3
./bootstrap --prefix=/usr/local
make
make install
export PATH=${PATH}:/usr/local/bin


yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)
yum install -y http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.0.130-1.x86_64.rpm
yum install -y epel-release
yum clean -y all
yum install -y cuda

mkdir -p /tmp/amber-build
cd /tmp && \
tar -xvf /tmp/AmberDownloads/Amber20.tar.bz2 -C /tmp/amber-build && \
tar -xvf /tmp/AmberDownloads/AmberTools20.tar.bz2 -C /tmp/amber-build

AMBER_PREFIX=/tmp/amber-build
cd /tmp/amber-build/amber20_src/build && \

# Permit builds with CUDA 11.0 #
sed -i 's/10.2/11.0/g' /tmp/amber-build/amber20_src/cmake/CudaConfig.cmake
# Remove sm_30 spec and replace with sm_35, sm_37
sed -i 's/\${SM30FLAGS}/\${SM35FLAGS} \${SM37FLAGS}/g' /tmp/amber-build/amber20_src/cmake/CudaConfig.cmake
cmake $AMBER_PREFIX/amber20_src \
    -DCMAKE_INSTALL_PREFIX=/apps/amber20 \
    -DCOMPILER=GNU  \
    -DMPI=FALSE -DCUDA=TRUE -DINSTALL_TESTS=TRUE \
    -DDOWNLOAD_MINICONDA=TRUE -DMINICONDA_USE_PY3=TRUE \
    2>&1 | tee  cmake.log
make install

cat <<EOT >> /etc/profile.d/amber.sh
#!/bin/bash
. /apps/amber20/amber.sh
EOT

