########################################
Build your application
#########################################


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
* `_MACHINE_TYPE` - The type of machine to use to build the image. When packer is used to bake a VM image, it creates a GCE instance on which it runs the installation steps. The size and shape of this instance is determined by this variable.


While the default values have been generally tested, the value of these variables can be modified when executing a build using `--substitutions=`, e.g.
```
gcloud builds submit . --async --project=PROJECT-ID --substitutions=_SOURCE_IMAGE_FAMILY=centos-7,_SOURCE_IMAGE_PROJECT=centos-cloud --config=wrf/cloudbuild.yaml
```

### Common Base Images

**Research Computing Cluster Images**
* CentOS 7, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-centos-7-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
* Debian 10, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-debian-10-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`
* Ubuntu 20.04, RCC Image - `_SOURCE_IMAGE_FAMILY=rcc-ubuntu-2004-v3, _SOURCE_IMAGE_PROJECT=fluid-cluster-ops`


* CentOS 7 - `_SOURCE_IMAGE_FAMILY=centos-7, _SOURCE_IMAGE_PROJECT=centos-cloud`
* Debian 10 - `_SOURCE_IMAGE_FAMILY=debian-10, _SOURCE_IMAGE_PROJECT=debian-cloud`
* Ubuntu 20.04 - `_SOURCE_IMAGE_FAMILY=ubuntu-2004-lts, _SOURCE_IMAGE_PROJECT=ubuntu-os-cloud`
* CentOS 7 HPC VM Image - `_SOURCE_IMAGE_FAMILY=hpc-centos-7, _SOURCE_IMAGE_PROJECT=click-to-deploy-images`

**Slurm-GCP Compatible Base Images**
* CentOS 7, HPC SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-hpc-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* CentOS 7, SchedMD Slurm-GCP CentOS - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-centos-7, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
* Debian 10, SchedMD Slurm-GCP - `_SOURCE_IMAGE_FAMILY=schedmd-slurm-20-11-4-debian-10, _SOURCE_IMAGE_PROJECT=schedmd-slurm-public`
