#!/bin/bash


spack_install() {
  # This function attempts to install from the cache. If this fails, 
  # then it will install from source and create a buildcache for this package
  if [[ -n "$SPACK_BUCKET" ]]; then
    spack buildcache install "$1" || \
  	  ( spack install --no-cache "$1" && \
  	    spack buildcache create -a --rebuild-index \
  	                            -k ${INSTALL_ROOT}/spack/share/RCC_gpg \
				    -m RCC \
				    -f "$1" )
  else
     spack install "$1"
  fi
}

function system_deps(){

    yum install -y gcc gcc-c++ gcc-gfortran valgrind valgrind-devel mailx python3 python3-devel python3-pip
    pip3 install --upgrade google-cloud-storage google-api-python-client oauth2client google-cloud \
    	               cython pyyaml parse docopt jsonschema dictdiffer
}

function rocm_setup(){
    cat > /etc/yum.repos.d/rocm.repo <<EOL
[ROCm]
name=ROCm
baseurl=https://repo.radeon.com/rocm/yum/rpm
enabled=1
gpgcheck=1
gpgkey=https://repo.radeon.com/rocm/rocm.gpg.key
EOL
    yum update -y
    yum install -y rocm-dev

    cat > /etc/profile.d/z11_rocm.sh <<EOL
#!/bin/bash

export PATH=\${PATH}:/opt/rocm/bin
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/rocm/lib:/opt/rocm/lib64
EOL
}

system_deps

rocm_setup

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

# Install "after-market" compilers
COMPILERS=("gcc@11.2.0"
           "gcc@10.3.0"
	   "gcc@9.4.0")

for COMPILER in "${COMPILERS[@]}"; do
  spack_install "${COMPILER} % gcc@4.8.5 target=${ARCH}"
  spack load ${COMPILER} && spack compiler find --scope site && spack unload ${COMPILER}
done

spack compiler find --scope site
# Adjust the paths to AMD Clang/Flang compilers
sed -i "s#cc: /bin/clang-ocl#cc: /opt/rocm/bin/amdclang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#cxx: null#cxx: /opt/rocm/bin/amdclang++#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#f77: null#f77: /opt/rocm/bin/amdflang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#fc: null#fc: /opt/rocm/bin/amdflang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
cat ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml

# Install OpenMPI with desired compilers
COMPILERS=("gcc@11.2.0"
           "gcc@10.3.0"
           "gcc@9.4.0"
	   "clang@13.0.0")
for COMPILER in "${COMPILERS[@]}"; do
  if [[ "$COMPILER" == *"intel"* ]];then
    spack_install "openmpi@4.0.5 % intel target=${ARCH}"
  else
    spack_install "openmpi@4.0.5 % ${COMPILER} target=${ARCH}"
  fi
done

spack install singularity % gcc@9.4.0

spack gc -y


if [[ -n "$SPACK_BUCKET" ]]; then
  spack mirror rm RCC
fi

cat /dev/null > /var/log/messages
