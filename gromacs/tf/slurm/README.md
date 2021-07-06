# Overview

This example deploys a Slurm cluster in GCP with Gromacs installed along with the benchMEM, benchPEP, and benchRIB input decks. 
Users can use this example to stand up an autoscaling HPC cluster to run Gromacs molecular dynamics simulations on Google Cloud Platform 

# Configuration

# Deployment

1. Set the following environment variables
* `GMX_NAME` (Default :`"gromacs"`) - The name of your cluster
* `GMX_PROJECT` - Your GCP Project ID
* `GMX_ZONE` (Default : `"us-west1-b"`) - The GCP zone to deploy your cluster
* `GMX_MACHINE_TYPE` (Default : `"n1-standard-8"`) - The machine type for your compute nodes.
* `GMX_NODE_COUNT` (Default : 1) - The max number of compute nodes in the `gromacs` slurm partition
* `GMX_IMAGE` (Default : `"projects/hpc-apps/global/images/gromacs-gcp-foss-latest"`) - The VM image to use with your deployment. The default is the free and open-source Gromacs image from Fluid Numerics.
* `GMX_GPU_TYPE` (Default : `"nvidia-tesla-v100"`) - The GPU type to attach to compute nodes.
* `GMX_GPU_COUNT` (Default : `1`) - The number of GPUs per compute node.


2.  Make the plan
```make plan```
2. Review the plan
3. Deploy the solution
```make apply```

# Teardown

```make destroy```
