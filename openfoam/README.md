# OpenFOAM Google Cloud VM Image 


This build can be used to create a Google Cloud VM image with the following packages :
* OpenFOAM-Org (v8)
* Paraview-Server (v5.10) +MPI +EGL
* GMSH (v4.8.4)


## Build this Image

Default build parameters are provided to build OpenFOAM using GCC 10.2.0 with the `x86_64` target architecture. This build is the most portable across instances on Google Cloud. To run this build : 


1. [Open Google Cloud Shell](https://shell.cloud.google.com/?show=terminal)

2. Set your Google Cloud Project, replacing `<PROJECT_ID>` with your Google Cloud project ID.
```
gcloud config set project <PROJECT_ID>
```

3.  Clone the rcc-apps repository
```
git clone https://github.com/fluidnumerics/rcc-apps ~/rcc-apps
```

4. Navigate to the rcc-apps source code directory
```
cd ~/rcc-apps
```

5. Use Google Cloud Build to launch the build process
```
gcloud builds submit . --config=openfoam/cloudbuild.yaml --async
```

The build process can take up to 2 hours. You can monitor the status of your build from the [Google Cloud console](https://console.cloud.google.com/cloud-build/builds)


### Modifying the build
We have exposed a number of parameters to help you customize the build process :

* `_SOURCE_IMAGE_FAMILY` (Default: `'schedmd-slurm-20-11-7-centos-7'`) - The image family that you want to build on top of
* `_SOURCE_IMAGE_PROJECT` (Default: `'research-computing-cloud'`) - The project hosting the image family you want to build on top of
* `_IMAGE_NAME` (Default: ` 'openfoam-gcp-foss-latest'`) - The name for the resulting image
* `_IMAGE_FAMILY` (Default: ` 'openfoam-gcp-foss'`) - The image family for the resulting image
* `_INSTALL_ROOT` (Default: ` '/opt'`) - The path on the VM to use to install Spack and the Spack installed packages.
* `_SLURM_ROOT` (Default: ` '/usr/local'`) - The path to a Slurm installation, if available on the source image
* `_COMPILER` (Default: ` 'gcc@10.3.0'`) - The compiler you want to use to build OpenFOAM
* `_TARGET_ARCH` (Default: ` "x86_64"`) - The [target architecture](https://github.com/spack/spack/blob/develop/lib/spack/external/archspec/json/cpu/microarchitectures.json) to target during the build process.
* `_MACHINE_TYPE` (Default: ` "n1-standard-16"`) - The machine type to use for the imaging node
* `_SYSTEM_COMPILER` (Default: ` "gcc@4.8.5"`) - The compiler provided by the OS on the source image.

With Google Cloud Build,  you can override these parameters using the [`--substitutions` flag](https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values).


As an example, if you want to target the cascadelake architecture (c2 instances on Google Cloud), you can do
```
gcloud builds submit . --config=openfoam/cloudbuild.yaml --substitutions=_TARGET_ARCH=cascadelake --async
```	


### Building and benchmarking
In addition to the build pipeline for building the OpenFOAM image, we have provided a build pipeline that will build your image and run the included `damBreakFine` benchmark. Benchmarking is handled using the [fluid-run](https://fluid-run.readthedocs.io/en/latest/) build step. This tool provisions a Slurm controller and manages job scheduling via Cloud Build on your behalf to execute tests, which are defined in [`openfoam/fluidrun.yaml`](./fluidrun.yaml). Additionally, the build information is aligned with run time and resource usage information from the Slurm job scheduler and pushed to a Big Query data set. This allows you to completely version control the build and benchmarking process and enables comparisons of runtimes across various hardware and under different build settings.


**The default benchmarks require 240 c2 vCPU and 112 c2d vCPU and 1 TB PD-SSD. Verify you have sufficient quota before proceeding**

To get started wit building and benchmarking OpenFOAM,


1. [Open Google Cloud Shell](https://shell.cloud.google.com/?show=terminal)

2. Set your Google Cloud Project, replacing `<PROJECT_ID>` with your Google Cloud project ID.
```
gcloud config set project <PROJECT_ID>
```

3.  Clone the rcc-apps repository, if you have not done so already
```
git clone https://github.com/fluidnumerics/rcc-apps ~/rcc-apps
```

4. Edit the fluid.auto.tfvars Terraform variables file that is used to provision resources required for fluid-run. At a minimum, you will need to set `project` equal to your Google Cloud project ID.
```
cd ~/rcc-apps/tf
vim fluid.auto.tfvars
```

5. Create the Big Query dataset for storing benchmark output from fluid-run and network resources for the benchmarking cluster.
```
cd ~/rcc-apps/tf
terraform init
terraform apply
```

6. Once the resources are created, you can run the build pipeline for building OpenFOAM followed by benchmarking.
```
cd ~/rcc-apps/
gcloud builds submit . --config=openfoam/cloudbuild.benchmark.yaml --async
```

The build process can take up to 2 hours and benchmarking can take an additional 2-4 hours. You can monitor the status of your build from the [Google Cloud console](https://console.cloud.google.com/cloud-build/builds). Once the build is done, you will be able to see your benchmark results in [Big Query](https://console.cloud.google.com/bigquery). You can visualize benchmarking results and [explore your data further using Google's Data Studio](https://cloud.google.com/bigquery/docs/visualize-data-studio).

