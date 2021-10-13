#!/bin/bash

SYSTEM_COMPILER="gcc@8.3.0"
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

    export DEBIAN_FRONTEND=noninteractive
    sleep 30 # Wait for unattended-upgrades to stop 
    apt-get update -y 
    apt-get install -y libnuma-dev python3-dev python3-pip build-essential zip unzip
    pip3 install --upgrade google-cloud-storage google-api-python-client oauth2client google-cloud \
    	               cython pyyaml parse docopt jsonschema dictdiffer
}

system_deps

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

spack compiler find --scope site
# Install OpenMPI with desired compilers
COMPILERS=(${SYSTEM_COMPILER})
for COMPILER in "${COMPILERS[@]}"; do
  if [[ "$COMPILER" == *"intel"* ]];then
    spack_install "openmpi@4.0.5 % intel target=${ARCH}"
  else
    spack_install "openmpi@4.0.5 % ${COMPILER} target=${ARCH}"
  fi
done

# Singularity
spack_install singularity

# Checkpoint/Restart tools
spack_install "dmtcp target=${ARCH}"

# Profilers
spack_install "hpctoolkit@2021.05.15 +cuda~viewer target=${ARCH}"  # HPC Toolkit requires gcc 7 or above

# Benchmarks
spack_install hpcc % ${SYSTEM_COMPILER}
spack_install hpcg % ${SYSTEM_COMPILER}
spack_install osu-micro-benchmarks % ${SYSTEM_COMPILER}

spack gc -y

if [[ -n "$SPACK_BUCKET" ]]; then
  spack mirror rm RCC
fi

mkdir /apps/workspace
chmod ugo=rwx -R /apps/workspace

cat /dev/null > /var/log/syslog
