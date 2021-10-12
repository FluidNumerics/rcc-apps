########################################
Base Images
#########################################

Base images are the VM images that you can start from to create your application. Choosing a base image depends on the operating system you prefer, packages that you want to have installed, and whether or not you want support.

The Research Computing Cloud (RCC) images come with the Slurm job scheduler, Spack, and Singularity. On Ubuntu and CentOS solutions, RCC images also come with ROCm for portable GPU programming. The RCC images are offered with either no support (free) or with support (scalable license fee). Alternatively, you can use the RCC-Apps repository to build your own image library from scratch.


***************************
Free RCC Images
***************************
"Free" Images are VM images that do not incur additional licensing fees on Google Cloud. These images do not come with any support, but can provide a good starting point for you to experiment with building your application. In addition to some of the OS images provided by Google Cloud, Fluid Numerics offers a few free VM images that are created from the `rcc-apps repository <https://github.com/fluidnumerics/rcc-apps>`_.


RCC (CentOS 7) (FOSS)
======================
The RCC CentOS 7 FOSS VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 11.2.0 + OpenMPI 4.0.2
* GCC 10.3.0 + OpenMPI 4.0.2
* GCC 9.4.0 + OpenMPI 4.0.2
* AOMP (Clang + OpenMP 5.0) + OpenMPI 4.0.2

The self-link for the RCC CentOS 7 FOSS image is :code:`projects/research-computing-cloud/global/images/family/rcc-centos-foss-v300` 

RCC (Debian 10) (FOSS)
======================
The RCC Debian 10 FOSS VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 9.3.0 + OpenMPI 4.0.2

The self-link for the RCC Debian 10 FOSS image is :code:`projects/research-computing-cloud/global/images/family/rcc-debian-foss-v300` 

RCC (Ubuntu 20.04) (FOSS)
======================
The RCC Ubuntu 20.04 FOSS VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 9.4.0 + OpenMPI 4.0.2

The self-link for the RCC Ubuntu 20.04 FOSS image is :code:`projects/research-computing-cloud/global/images/family/rcc-ubuntu-foss-v300` 

***************************
RCC Images with Support
***************************
Fluid Numerics provides RCC VM images that are licensed to you to provide basic support for getting started with the solution on Google Cloud. Use of these images, hosted by the Google Cloud Marketplace, incur a licensing fee of $0.01USD/vCPU/hour and $0.09USD/GPU/hour and entitles you to basic support during Fluid Numerics business hours (8AM-5PM US MT). When requesting support, you will need to provide your Google project ID and billing account ID to verify usage of a support-licensed VM image.

If you have a large compute project planned, reach out to support@fluidnumerics.com to discuss licensing discounts and other licensing models.

RCC (CentOS 7) (Marketplace)
=============================
The RCC CentOS 7 Marketplace VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 11.2.0 + OpenMPI 4.0.2
* GCC 10.3.0 + OpenMPI 4.0.2
* GCC 9.4.0 + OpenMPI 4.0.2
* AOMP (Clang + OpenMP 5.0) + OpenMPI 4.0.2
* cluster-services

The self-link for the RCC CentOS 7 Marketplace image is :code:`projects/fluid-cluster-ops/global/images/family/rcc-centos-7-v300` 


RCC (Debian 10) (Marketplace)
===============================
The RCC Debian 10 Marketplace VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 9.3.0 + OpenMPI 4.0.2
* cluster-services

The self-link for the RCC Debian 10 Marketplace image is :code:`projects/fluid-cluster-ops/global/images/family/rcc-debian-10-v300` 

RCC (Ubuntu 20.04) (Marketplace)
==================================
The RCC Ubuntu 20.04 Marketplace VM image is built, maintained, and made publicly accessible by Fluid Numerics. This VM image includes the following applications installed, out-of-the-box

* Slurm 20.11
* Spack
* Singularity 3.7.4
* GCC 9.4.0 + OpenMPI 4.0.2
* cluster-services

The self-link for the RCC Ubuntu 20.04 Marketplace image is :code:`projects/fluid-cluster-ops/global/images/family/rcc-ubuntu-2004-v300` 
