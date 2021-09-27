#!/bin/bash


spack_install() {
  # This function attempts to install from the cache. If this fails, 
  # then it will install from source and create a buildcache for this package
  if [ -z "$SPACK_BUCKET" ]; then
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

    export DEBIAN_FRONTEND=noninteractive
    dpkg  --configure -a
    apt-get update -y 
    apt-get install -y libnuma-dev python3-dev python3-pip build-essential zip unzip
    pip3 install --upgrade google-cloud-storage google-api-python-client oauth2client google-cloud \
    	               cython pyyaml parse docopt jsonschema dictdiffer
}

function rocm_setup(){
    wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
    echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list
    apt-get update -y
    apt-get install -y rocm-dev
    
    echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf
    echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf
    
    cat > /etc/profile.d/z11-rocm.sh << EOL
#!/bin/bash

export PATH=\${PATH}:/opt/rocm/bin
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/rocm/lib
export HIP_PLATFORM=nvcc

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

spack gc -y

if [ -z "$SPACK_BUCKET" ]; then
  spack mirror rm RCC
fi

cat /dev/null > /var/log/syslog