# Overview

This example deploys a Slurm cluster in GCP with the Weather Research and Forecasting (WRF) model (v4) installed along with CONUS 2.5km and CONUS 12km input decks. Users can use this example to stand up an autoscaling HPC cluster to run WRF simulations on Google Cloud Platform 

# Configuration

## tf/examples/singularity/basic.tfvars

Supply values for
- cluster_name: the name of cluster you will deploy to GCP
- project: the GCP project that will host your cluster resources
- zone: the GCP zone where your cluster resources will be deployed
- partitions: information about the Slurm partitions your cluster makes available to cluster users

## tf/examples/singularity/custom-controller-install

Supply values for
- `PROJECT_ID` : The GCP project ID where you are deploying the cluster. This is needed to pull input deck data from a publicly available GCE bucket. 

# Deployment

1. Make the plan
```make plan```
2. Review the plan
3. Deploy the solution
```make apply```

# Teardown

```make destroy```
