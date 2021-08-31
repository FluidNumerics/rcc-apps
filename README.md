# Research Computing Cloud - Applications
Copyright 2021 Fluid Numerics LLC

This repository contains code for creating VM images compatible with Fluid Numerics Research Computing Cluster and the open-source [Slurm-GCP](https://github.com/schedmd/slurm-gcp).


## HPC Applications in the Cloud
Fluid Numerics intends to provide you with many options for getting started with HPC and Research Computing applications on Google Cloud.



## Getting Started
Each subdirectory in this repository contains
* `packer.json` - [Packer](https://packer.io) build script
* `cloudbuild.yaml` - [Cloud Build](https://cloud.google.com/build)
* `install.sh` - An installation file for the package
* `env/spack.yaml` - A [Spack environment](https://spack.readthedocs.io/en/latest/environments.html) file
* `tf/` - An example Terraform deployment for using your VM image.

### Building a package
Each package is built on top of an existing and publicly available VM image on Google Cloud. By default, most packages build on top of the [Slurm-GCP](https://console.cloud.google.com/marketplace/product/schedmd-slurm-public/schedmd-slurm-gcp) marketplace solution. Building on top of the VM image for this solution will provide you with a VM image that is capable of being used with the Slurm-GCP solution.

To build one of the packages, simply submit the build to cloud build using one of the application's provided cloudbuild.yaml file, e.g.

```
gcloud builds submit . --async --project=PROJECT-ID --config=wrf/cloudbuild.yaml
```
The default parameters for the build are configured to provide a working build. When possible, we strive to provide default build configurations that provide optimal performance.

### Understanding the Cloud Build files
Each `cloudbuild.yaml` has the following variables

* `_ZONE` -  The GCP Zone where the imaging node is deployed
* `_SUBNETWORK` - The GCP Subnet used to deploy the imaging node
* `_SOURCE_IMAGE_FAMILY` - The name of the VM image family on GCP to start the build from. Using the image family pulls the latest image in that family
* `_SOURCE_IMAGE_PROJECT` - The GCP project hosting the VM image
* `_IMAGE_NAME` - The name of the resulting VM image
* `_IMAGE_FAMILY` - The name of the VM image family to sort the resulting image
* `_INSTALL_ROOT` - The location within the VM image where Spack and the HPC packages are installed
* `_SLURM_ROOT` - The location where Slurm is installed; this is only relevant for `SOURCE_IMAGE_FAMILY` choices where Slurm is already installed
* `_COMPILER` - The compiler name and version, used by Spack, to build your application (e.g. `gcc@10.2.0`)
* `_PKG_PATH` - The path in this repository to your packages installation scripts.
* `_COMMON_PATH` - The path to the `common/` directory in this repository
* `_TARGET_ARCH` - The target architecture to pass to Spack's `target` flag (e.g. `target=${_TARGET_ARCH}`)
* `_ENV_FILE` - The path, relative to `_PKG_PATH` to the spack environment file. The default is set to `env/spack.yaml`. This is useful if you are changing the `_SOURCE_IMAGE_FAMILY` and need to modify the system provided packags.


While the default values have been generally tested, the value of these variables can be modified when executing a build using `--substitutions=`, e.g.
```
gcloud builds submit . --async --project=PROJECT-ID --substitutions=_SOURCE_IMAGE_FAMILY=centos-7,_SOURCE_IMAGE_PROJECT=centos-cloud --config=wrf/cloudbuild.yaml
```

### Common Base Images

**Research Computing Cluster Images**
* CentOS 7, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-centos-7-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
* Debian 10, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-debian-10-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
* Ubuntu 20.04, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-ubuntu-2004-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`

**Base Operating System Images**
* CentOS 7 - `_SOURCE_IMAGE_FAMILY=centos-7, _SOURCE_IMAGE_PROJECT=centos-cloud`
* Debian 10 - `_SOURCE_IMAGE_FAMILY=debian-10, _SOURCE_IMAGE_PROJECT=debian-cloud`
* Ubuntu 20.04 - `_SOURCE_IMAGE_FAMILY=ubuntu-2004-lts, _SOURCE_IMAGE_PROJECT=ubuntu-os-cloud`
* CentOS 7 HPC VM Image - `_SOURCE_IMAGE_FAMILY=hpc-centos-7, _SOURCE_IMAGE_PROJECT=click-to-deploy-images`

**Slurm-GCP Compatible Base Images**
* CentOS 7, HPC SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-hpc-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* CentOS 7, SchedMD Slurm-GCP CentOS - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* Debian 10, SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-debian-10, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`


### Deploying VM Images

#### Free and Open Source Solutions
Fluid Numerics develops and maintains this repository to help you get started with VM image baking and Terraform infrastructure-as-code. 
Some VM images are sponsored by organizations to make them freely available to the community for use. These free images are licensed for use under the [Apache 2.0 License](./LICENSE)

**Freely available images**
* [**Gromacs**](./gromacs/tf/slurm) - `selfLink: projects/hpc-apps/global/images/gromacs-gcp-foss-latest`
* [**WRF v4.2**](./wrf/tf/slurm) - `selfLink: projects/hpc-apps/global/images/wrf-gcp-slurm-gcp-centos7-latest`


## Getting support
Fluid Numerics provides support and consulting services to help you get up and running on Google Cloud. [Reach out to Fluid Numerics for Support](https://help.fluidnumerics.com/support)

### Fluid Numerics' Research Computing Cloud VM Image Library
Fluid Numerics builds and tests all of the applications in this repository and actively supports adding upgrades and updates to our managed VM library. Access to the RCC VM image library also comes with support from Fluid Numerics to help you use these images. 

The RCC VM Image Library and our open-source [`rcc-apps-tf`](https://github.com/FluidNumerics/rcc-apps-tf) infrastructure-as-code can save you time in cloud design and engineering and provide you access to tested VM images ready for launch on GCP alongside professional and technical support from Fluid Numerics.


Images that are currently available :

Image Contents | Image Family
-------------- | ------------
GCC 9.4.0, 10.2.0, 10.3.0, 11.2.0; Intel Compilers 2021; AOMP Compiler 13.0.0; OpenMPI 4.0.2, Singularity, ROCm 4.3 (CentOS 7) | rcc-centos-7-v3 
GCC 9.4.0, 10.2.0, 10.3.0, 11.2.0; Intel Compilers 2021; AOMP Compiler 13.0.0; OpenMPI 4.0.2, Singularity, ROCm 4.3 (Debian 10) | rcc-debian-10-v3 
GCC 9.4.0, 10.2.0, 10.3.0, 11.2.0; Intel Compilers 2021; AOMP Compiler 13.0.0; OpenMPI 4.0.2, Singularity, ROCm 4.3 (Ubuntu 20.04) | rcc-ubuntu-2004-v3 
OpenFOAM v8 + Paraview 5.9.0 (GCC 11.2.0 + OpenMPI 4.0.2) (Cascadelake) | rcc-openfoam-gcc-ompi-cascadelake
OpenFOAM v8 + Paraview 5.9.0 (GCC 11.2.0 + OpenMPI 4.0.2) (Zen3) | rcc-openfoam-gcc-ompi-zen3
OpenFOAM v8 + Paraview 5.9.0 (GCC 11.2.0 + OpenMPI 4.0.2) (x86) | rcc-openfoam-gcc-ompi-x86_64
WRF v4.2 (GCC 9.4.0 + OpenMPI 4.0.2) (Cascadelake)| rcc-wrf-gcc-ompi-cascadelake
WRF v4.2 (Clang 13.0.0 + OpenMPI 4.0.2) (Zen3)| rcc-wrf-clang-ompi-zen3
WRF v4.2 (Intel OneAPI Compilers + OpenMPI 4.0.2) (Cascadelake) | rcc-wrf-intel-ompi-cascadelake
Gromacs 2021.2 (GCC 10.2.0 + CUDA 11) (Cascadelake) | rcc-gromacs-gcc-cascadelake
Gromacs 2021.2 (Intel OneAPI Compilers + CUDA 11) (Cascadelake) | rcc-gromacs-intel-cascadelake
Gromacs 2021.2 (GCC 10.2.0 + CUDA 11) (Broadwell) | rcc-gromacs-gcc-broadwell
Gromacs 2021.2 (Intel OneAPI Compilers + CUDA 11) (Broadwell) | rcc-gromacs-intel-broadwell
