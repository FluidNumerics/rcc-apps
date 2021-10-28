# Overview

This example deploys a Slurm cluster in GCP with the Weather Research and Forecasting (WRF) model (v4) installed along with CONUS 2.5km and CONUS 12km input decks. Users can use this example to stand up an autoscaling HPC cluster to run WRF simulations on Google Cloud Platform 

# Deployment
1. Set the following environment variables to customize your deployment
* `WRF_NAME` (default : `"wrf-demo"`) - The name of your deployment. This name prefixes your controller and login node instances for your cluster.
* `WRF_PROJECT` - The GCP project ID you want to deploy your cluster to. This environment variable must be set.
* `WRF_ZONE` (default : `"us-west1-b"`) - The GCP Zone to deploy the cluster to
* `WRF_MACHINE_TYPE` (default : `"c2-standard-8"`) - The GCE Instance type you want to use for compute nodes that will run WRF
* `WRF_MAX_NODE` (default : 3) - The maximum number of GCE instances available in your slurm partition for running WRF.
* `WRF_IMAGE` (default : `"projects/hpc-apps/global/images/wrf-gcp-slurm-gcp-centos7-latest"`) - The VM image to use to run WRF. 

2.  Make the plan
```make plan```

3. Review the plan

4. Deploy the solution
```make apply```

# Teardown
When you are ready to delete your cluster, you can simply run `make destroy` from this directory.


# Codelabs

* [Run the WRF Weather Forecasting Model on Google Cloud using Slurm-GCP and Terraform Infrastructure-as-Code](https://fluid-slurm-gcp-codelabs.web.app/run-wrf-on-slurm-gcp-with-terraform/index.html#0)
