# HPC Apps for GCP
Copyright 2021 Fluid Numerics LLC

This repository contains code for creating VM images compatible with [Slurm-GCP](https://github.com/schedmd/slurm-gcp) that have common HPC applications pre-installed.

Fluid Numerics provides support and consulting services to help you get up and running on Google Cloud. [Reach out to Fluid Numerics for Support](https://help.fluidnumerics.com/support)

## HPC Applications in the Cloud
Fluid Numerics intends to provide you with many options for getting started with HPC and Research Computing applications on Google Cloud.



### Free and Open Source Solutions
Fluid Numerics develops and maintains this repository to help you get started with VM image baking and Terraform infrastructure-as-code. 

Some VM images are sponsored by organizations to make them freely available to the community for use. These free images are licensed for use under the [Apache 2.0 License](./LICENSE)

**Freely available images**
* **Gromacs** - `selfLink: projects/hpc-apps/global/images/gromacs-gcp-foss-latest`
* **WRF v4.2** - `selfLink: projects/hpc-apps/global/images/wrf-gcp-slurm-gcp-centos7-latest`


### Fluid Numerics' HPC Apps VM Image Library
Fluid Numerics builds all of the applications in this repository, provides useful base images with a variety of compiler stacks, and actively supports adding upgrades and updates to our managed VM library. Access to this VM image library also comes with support from Fluid Numerics to help you use these images. This can save you time in cloud design and engineering and provide you access to tested VM images ready for launch on GCP.

We currently offer the following images through a VM Image Library subscription with Fluid Numerics

Image Contents | Image Family | Image Name
-------------- | ------------ | ----------
GCC 7.5.0, 8.5.0, 9.4.0, 10.2.0; Intel Compilers 2021, OpenMPI 4.0.2, Singularity, ROCm, lmod | fluid-hpc-centos-7-devplatform | fluid-hpc-centos-7-devplatform-1e35f2d
Singularity (GCC 10.2.0 + OpenMPI 4.0.2) | fluid-hpc-singularity-gcc-10-ompi-4 | fluid-hpc-singularity-gcc-10-ompi-4-
OpenFOAM v8 + Paraview 5.9.0 (GCC 10.2.0 + OpenMPI 4.0.2) | fluid-hpc-openfoam-gcc-10-ompi-4 | fluid-hpc-openfoam-gcc-10-ompi-4-2f78318
WRF v4.2 (GCC 9.4.0 + OpenMPI 4.0.2) | fluid-hpc-wrf-gcc-9-ompi-4 | fluid-hpc-wrf-gcc-9-ompi-4-99596c7
WRF v4.2 (Intel OneAPI Compilers + OpenMPI 4.0.2) | fluid-hpc-wrf-intel-oneapi-compilers-ompi-4 | fluid-hpc-wrf-intel-oneapi-compilers-ompi-4-99596c7
Gromacs 2021.2 (GCC 10.2.0 + CUDA 11) | fluid-hpc-gromacs-gcc-10 | fluid-hpc-gromacs-gcc-10-
GCC 10.2.0 | fluid-hpc-centos-7-gcc-10-2-0 | fluid-hpc-centos-7-gcc-10-2-0-e7a73f9
GCC 9.4.0 | fluid-hpc-centos-7-gcc-9-4-0 | fluid-hpc-centos-7-gcc-9-4-0-b97e4d2
GCC 8.5.0 | fluid-hpc-centos-7-gcc-8-5-0 | fluid-hpc-centos-7-gcc-8-5-0-b97e4d2
GCC 7.5.0 | fluid-hpc-centos-7-gcc-7-5-0 | fluid-hpc-centos-7-gcc-7-5-0-b97e4d2
Intel OneAPI Compilers 2021 | fluid-hpc-centos-7-intel-oneapi-compilers | fluid-hpc-centos-7-intel-oneapi-compilers-e7a73f9

**Notes**
* If you want to build images on top of these image, you need to set `_SOURCE_IMAGE_PROJECT=hpc-apps` and set `_SOURCE_IMAGE_FAMILY` to the value in the "Image Family" column from the table above.
* When deploying one of these images with the terraform deployments in this repository, you need to set the VM image to `projects/hpc-apps/global/images/IMAGE-NAME`, replacing `IMAGE-NAME`  with a value in the "Image Name" column from the table above.


Images currently in development
* **Paraview**
* **FEOTS**
* **SELF-Fluids**

## Getting Started
Each subdirectory in this repository contains
* `packer.json` - [Packer](https://packer.io) build script
* `cloudbuild.yaml` - [Cloud Build](https://cloud.google.com/build)
* `install.sh` - An installation file for the package

Each package, by default, builds on top of the [Slurm-GCP](https://console.cloud.google.com/marketplace/product/schedmd-slurm-public/schedmd-slurm-gcp) marketplace solution. Building on top of the VM image for this solution will provide you with a VM image that is capable of being used with the Slurm-GCP solution.

### Prerequisites
* [gcloud SDK](https://cloud.google.com/sdk/docs/install)
* Active GCP project

### Building a package
To build one of the packages, submit the build to cloud build using one of the application's provided cloudbuild.yaml file, e.g.

```
gcloud builds submit . --async --project=PROJECT-ID --config=wrf/cloudbuild.yaml
```

### Understanding the Cloud Build files
Each `cloudbuild.yaml` has the following variables

* `_ZONE` -  The GCP Zone where the imaging node is deployed
* `_SUBNETWORK` - The GCP Subnet used to deploy the imaging node
* `_SOURCE_IMAGE_FAMILY` - The name of the VM image family on GCP to start the build from. Using the image family pulls the latest image in that family
* `_SOURCE_IMAGE_PROJECT` - The GCP project hosting the VM image
* `_IMAGE_NAME` - The name of the resulting VM image
* `_IMAGE_FAMILY` - The name of the VM image family to sort the resulting image
* `_INSTALL_ROOT` - The location within the VM image where Spack and the HPC packages are installed

The value of these variables can be changed when executing a build using `--substitutions=`, e.g.
```
gcloud builds submit . --async --project=PROJECT-ID --substitutions=_SOURCE_IMAGE=centos-7-v20210401,_SOURCE_IMAGE_PROJECT=centos-cloud
```


### Common Base Images

**Fluid HPC Apps VM Image Library Base Images**
*VM Image Library access available via subscription*

* CentOS 7 + Slurm + GCC@10.2.0 - `_SOURCE_IMAGE_FAMILY=fluid-hpc-centos-7-gcc-10-2-0, _SOURCE_IMAGE_PROJECT=hpc-apps`
* CentOS 7 + Slurm + GCC@9.4.0 - `_SOURCE_IMAGE_FAMILY=fluid-hpc-centos-7-gcc-9-4-0, _SOURCE_IMAGE_PROJECT=hpc-apps`
* CentOS 7 + Slurm + GCC@8.5.0 - `_SOURCE_IMAGE_FAMILY=fluid-hpc-centos-7-gcc-8-5-0, _SOURCE_IMAGE_PROJECT=hpc-apps`
* CentOS 7 + Slurm + GCC@7.5.0 - `_SOURCE_IMAGE_FAMILY=fluid-hpc-centos-7-gcc-7-5-0, _SOURCE_IMAGE_PROJECT=hpc-apps`
* CentOS 7 + Slurm + Intel@2021 - `_SOURCE_IMAGE_FAMILY=fluid-hpc-centos-7-intel-oneapi-compilers, _SOURCE_IMAGE_PROJECT=hpc-apps`

*To use the Fluid HPC Apps VM Image Library Base Images, you must set the `_INSTALL_ROOT=/opt`*


**Base Operating System Images**
* CentOS 7 - `_SOURCE_IMAGE_FAMILY=centos-7, _SOURCE_IMAGE_PROJECT=centos-cloud`
* Debian 10 - `_SOURCE_IMAGE_FAMILY=debian-10, _SOURCE_IMAGE_PROJECT=debian-cloud`
* Ubuntu 20.04 - `_SOURCE_IMAGE_FAMILY=ubuntu-2004-lts, _SOURCE_IMAGE_PROJECT=ubuntu-os-cloud`
* CentOS 7 HPC VM Image - `_SOURCE_IMAGE_FAMILY=hpc-centos-7, _SOURCE_IMAGE_PROJECT=click-to-deploy-images`

**Slurm-GCP Compatible Base Images**
* CentOS 7, HPC SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-hpc-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* CentOS 7, SchedMD Slurm-GCP CentOS - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* Debian 10, SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-debian-10, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`


**Fluid-Slurm-GCP Compatible Base Images**
* CentOS 7, Fluid-Slurm-GCP - `_SOURCE_IMAGE_FAMILY=fluid-slurm-gcp-compute-centos, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
* Ubuntu 20.04, Fluid-Slurm-GCP - `_SOURCE_IMAGE_FAMILY=fluid-slurm-gcp-compute-ubuntu, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
