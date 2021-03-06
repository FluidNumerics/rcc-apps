#!/bin/bash


SYSTEM_COMPILER="gcc@4.8.5"
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
	   "gcc@9.4.0"
	   "intel-oneapi-compilers@2021.3.0")

for COMPILER in "${COMPILERS[@]}"; do
  spack_install "${COMPILER} % gcc@4.8.5 target=${ARCH}"
  spack load ${COMPILER} && spack compiler find --scope site && spack unload ${COMPILER}
done

# Adjust the paths to AMD Clang/Flang compilers
sed -i "s#.*clang-ocl.*#      cc: /opt/rocm/bin/amdclang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#cxx: null#cxx: /opt/rocm/bin/amdclang++#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#f77: null#f77: /opt/rocm/bin/amdflang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml
sed -i "s#fc: null#fc: /opt/rocm/bin/amdflang#" ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml

cat ${INSTALL_ROOT}/spack/etc/spack/compilers.yaml

# Install OpenMPI with desired compilers
COMPILERS=("gcc@11.2.0"
           "gcc@10.3.0"
           "gcc@9.4.0"
	   "clang@13.0.0"
	   "intel")

for COMPILER in "${COMPILERS[@]}"; do
  if [[ "$COMPILER" == *"intel"* ]];then
    spack_install "openmpi@4.0.5 % intel target=${ARCH}"
    # Benchmarks
    spack_install "hpcc % intel target=${ARCH}"
    spack_install "hpcg % intel target=${ARCH}"
    spack_install "osu-micro-benchmarks % intel"
  else
    spack_install "openmpi@4.0.5 % ${COMPILER} target=${ARCH}"
    # Benchmarks
    spack_install "hpcc % ${COMPILER} target=${ARCH}"
    spack_install "hpcg % ${COMPILER} target=${ARCH}"
    spack_install "osu-micro-benchmarks % ${COMPILER} target=${ARCH}"
  fi
done

# Singularity
spack_install "singularity % gcc@9.4.0 target=${ARCH}"

# Checkpoint/Restart tools
spack_install "dmtcp % ${SYSTEM_COMPILER} target=${ARCH}"

# Profilers
spack_install "hpctoolkit@2021.05.15 +cuda~viewer % gcc@10.3.0 target=${ARCH}"  # HPC Toolkit requires gcc 7 or above
spack_install "intel-oneapi-advisor % ${SYSTEM_COMPILER} target=${ARCH}"
spack_install "intel-oneapi-vtune % ${SYSTEM_COMPILER} target=${ARCH}"
spack_install "intel-oneapi-inspector % ${SYSTEM_COMPILER} target=${ARCH}"

# Remove unused packages
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
  echo "module use ${INSTALL_ROOT}/spack/share/spack/lmod/linux-centos7-x86_64/Core" >> /etc/profile.d/z10_spack_environment.sh

fi


if [[ -n "$SPACK_BUCKET" ]]; then
  spack mirror rm RCC
fi

mkdir /apps/workspace
chmod ugo=rwx -R /apps/workspace

cat /dev/null > /var/log/messages
