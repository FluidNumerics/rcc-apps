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
* `_SOURCE_IMAGE` - The name of the VM image on GCP to start the build from
* `_SOURCE_IMAGE_PROJECT` - The GCP project hosting the VM image
* `_IMAGE_NAME` - The name of the resulting VM image
* `_IMAGE_FAMILY` - The name of the VM image family to sort the resulting image

The value of these variables can be changed when executing a build using `--substitutions=`, e.g.
```
gcloud builds submit . --async --project=PROJECT-ID --substitutions=_SOURCE_IMAGE=centos-7-v20210401,_SOURCE_IMAGE_PROJECT=centos-cloud
```


