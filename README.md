# HPC Apps for GCP
Copyright 2021 Fluid Numerics LLC

This repository contains code for creating VM images compatible with [Slurm-GCP](https://github.com/schedmd/slurm-gcp) that have common HPC applications pre-installed.

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
To build one of the packages navigate to the package subdirectory, e.g.
```
cd wrf/
```
Submit the build to cloud build

```
gcloud builds submit . --async --project=PROJECT-ID
```

### Understanding the Cloud Build files
Each `cloudbuild.yaml` has the following variables

* `_ZONE` -  The GCP Zone where the imaging node is deployed
* `_SUBNETWORK` - The GCP Subnet used to deploy the imaging node
* `_SOURCE_IMAGE_FAMILY` - The name of the VM image family on GCP to start the build from. Using the image family pulls the latest image in that family
* `_SOURCE_IMAGE_PROJECT` - The GCP project hosting the VM image
* `_IMAGE_NAME` - The name of the resulting VM image
* `_IMAGE_FAMILY` - The name of the VM image family to sort the resulting image

The value of these variables can be changed when executing a build using `--substitutions=`, e.g.
```
gcloud builds submit . --async --project=PROJECT-ID --substitutions=_SOURCE_IMAGE=centos-7-v20210401,_SOURCE_IMAGE_PROJECT=centos-cloud
```


### Common Base Images

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
