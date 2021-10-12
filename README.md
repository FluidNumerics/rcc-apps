# Research Computing Cloud - Applications
Copyright 2021 Fluid Numerics LLC

Fluid Numerics intends to provide you with many options for getting started with HPC and Research Computing (RC) applications on Google Cloud. This repository contains code for creating VM images compatible with [Fluid Numerics Research Computing Cluster](https://help.fluidnumerics.com/#h.ijjdzwcel1y4) and the open-source [Slurm-GCP](https://github.com/schedmd/slurm-gcp).


## Support
Issues, feature requests, and general support requests can be submitted through [Fluid Numerics' Community Support channel](https://fluid-run.readthedocs.io/en/latest/Support/support.html)


## Documentation
Documentation is available at https://fluid-run.readthedocs.io/en/latest/



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

The RCC VM Image Library and our open-source [`rcc-tf`](https://github.com/FluidNumerics/rcc-tf) infrastructure-as-code can save you time in cloud design and engineering and provide you access to tested VM images ready for launch on GCP alongside professional and technical support from Fluid Numerics.


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
