# Paraview Google Cloud VM Image 


This build can be used to create a Google Cloud VM image with the following packages :
* Paraview-Server (v5.10) +MPI +OSMesa


## Build this Image

To run this build : 


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
gcloud builds submit . --config=paraview/cloudbuild.yaml --async
```

The build process can take up to 30 minutes. You can monitor the status of your build from the [Google Cloud console](https://console.cloud.google.com/cloud-build/builds)


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


Currently, Paraview is installed using pre-compiled binaries from https://paraview.org; changing target architecture and compiler does not influence changes in the installation process.
