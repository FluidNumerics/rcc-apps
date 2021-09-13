# Overview


# Deployment
1. Set the following environment variables to customize your deployment
* `HPC_NAME` (default : `"wrf-demo"`) - The name of your deployment. This name prefixes your controller and login node instances for your cluster.
* `HPC_PROJECT` - The GCP project ID you want to deploy your cluster to. This environment variable must be set.
* `HPC_ZONE` (default : `"us-west1-b"`) - The GCP Zone to deploy the cluster to
* `HPC_MACHINE_TYPE` (default : `"c2-standard-8"`) - The GCE Instance type you want to use for compute nodes that will run HPC
* `HPC_MAX_NODE` (default : 3) - The maximum number of GCE instances available in your slurm partition for running HPC.
* `HPC_IMAGE` (default : `"projects/${HPC_PROJECT}/global/images/hpc-benchmarks-foss-latest"`) - The VM image to use to run HPC. 

2.  Make the plan
```make plan```

3. Review the plan

4. Deploy the solution
```make apply```

# Teardown
When you are ready to delete your cluster, you can simply run `make destroy` from this directory.

