# OpenFOAM 
Copyright 2021 Fluid Numerics LLC

Maintainers: @schoonovernumerics

## How to use this image
This image installs OpenFOAM and Paraview via spack into the directory specified by `_INSTALL_ROOT`. lmod modules are used to allow OpenFOAM and Paraview to be called into your path. When using this image, we recommend the following workflow

```
# Load OpenFOAM and Paraview into your path
module load gcc
module load openmpi
module load openfoam paraview
```
