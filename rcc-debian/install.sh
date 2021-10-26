#!/bin/bash

SYSTEM_COMPILER="gcc@8.3.0"
spack_install() {
  # This function attempts to install from the cache. If this fails, 
  # then it will install from source and create a buildcache for this package
  if [[ -n "$SPACK_BUCKET" ]]; then
    spack buildcache install "$1" || \
  	  ( spack install --source --no-cache "$1" && \
  	    spack buildcache create -a --rebuild-index \
  	                            -k ${INSTALL_ROOT}/spack/share/RCC_gpg \
				    -m RCC \
				    -f "$1" )
  else
     spack install --source "$1"
  fi
}

source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh

spack_install "intel-oneapi-compilers@2021.3.0 target=${ARCH}"
spack load intel-oneapi-compilers@2021.3.0
spack compiler find --scope site
spack unload intel-oneapi-compilers

# Install OpenMPI with desired compilers
COMPILERS=(${SYSTEM_COMPILER}
           "intel-oneapi-compilers@2021.3.0")
for COMPILER in "${COMPILERS[@]}"; do
  if [[ "$COMPILER" == *"intel"* ]];then
    spack_install "openmpi@4.0.5 % intel target=${ARCH}"
    # Benchmarks
    spack_install "hpcc % intel target=${ARCH}"
    spack_install "hpcg % intel target=${ARCH}"
    spack_install "osu-micro-benchmarks % intel target=${ARCH}"
  else
    spack_install "openmpi@4.0.5 % ${COMPILER} target=${ARCH}"
    # Benchmarks
    spack_install "hpcc % ${COMPILER} target=${ARCH}"
    spack_install "hpcg % ${COMPILER} target=${ARCH}"
    spack_install "osu-micro-benchmarks % ${COMPILER} target=${ARCH}"
  fi
done

# Singularity
spack_install "singularity target=${ARCH}"

# Checkpoint/Restart tools
spack_install "dmtcp target=${ARCH}"

# Profilers
spack_install "hpctoolkit@2021.05.15 +cuda~viewer target=${ARCH}"  # HPC Toolkit requires gcc 7 or above
spack_install "intel-oneapi-advisor % ${SYSTEM_COMPILER} target=${ARCH}"
spack_install "intel-oneapi-vtune % ${SYSTEM_COMPILER} target=${ARCH}"
spack_install "intel-oneapi-inspector % ${SYSTEM_COMPILER} target=${ARCH}"

spack gc -y
# Install lmod (for modules support)
# ** Currently in testing ** #
if [[ -f "/tmp/modules.yaml" ]]; then
  spack_install "lmod % ${SYSTEM_COMPILER} target=${ARCH}"
  spack gc -y
  source $(spack location -i lmod)/lmod/lmod/init/bash
  source ${INSTALL_ROOT}/spack/share/spack/setup-env.sh
  echo "Moving modules.yaml into site location"
  mv /tmp/modules.yaml ${INSTALL_ROOT}/spack/etc/spack/modules.yaml
  spack module lmod refresh --delete-tree -y

  # Remove tcl modules
  rm -rf ${INSTALL_ROOT}/spack/share/spack/modules

  # Add configurations to load lmod at login
  echo ". $(spack location -i lmod)/lmod/lmod/init/bash" >> /etc/profile.d/z10_spack_environment.sh
  echo ". \${SPACK_ROOT}/share/spack/setup-env.sh" >> /etc/profile.d/z10_spack_environment.sh
  echo "module unuse /usr/share/lmod/lmod/modulefiles/Core" >> /etc/profile.d/z10_spack_environment.sh
  echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-debian10-x86_64/Core" >> /etc/profile.d/z10_spack_environment.sh

fi

if [[ -n "$SPACK_BUCKET" ]]; then
  spack mirror rm RCC
fi

mkdir /apps/workspace
chmod ugo=rwx -R /apps/workspace

cat /dev/null > /var/log/syslog
