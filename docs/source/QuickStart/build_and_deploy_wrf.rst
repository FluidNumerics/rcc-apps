########################################
Build and Deploy WRF
########################################


Bake the VM Image
===================
When deploying resources on Google Cloud to run research computing applications, there are many options for installing and deploying your application. In this case, you will create a virtual machine image that builds on top of the RCC-CentOS (FOSS) VM image. During the installation process, this will install all of WRF’s dependencies and WRF while leveraging a compiler pre-installed on the RCC-CentOS (FOSS) VM image.

The `WRF Cloud Build pipeline <https://github.com/FluidNumerics/rcc-apps/blob/main/wrf/cloudbuild.yaml>`_ on the RCC Apps repository encapsulates the necessary instructions for installing WRF. Under the hood, the installation process uses Packer to deploy an imaging VM that verifies Spack is installed which in turn installs WRF@4.2 and any necessary dependencies with optimizations for Intel® Cascadelake architecture (c2 instances).

1. Open your Cloud Shell on GCP by going to https://shell.cloud.google.com?show=terminal
2. Clone the FluidNumerics/rcc-apps repository

.. code-block:: shell

    git clone https://github.com/FluidNumerics/rcc-apps.git ~/rcc-apps

3. Build the image using Google Cloud Build. You can check the status of your build process at the `Google Cloud Build dashboard <https://console.cloud.google.com/cloud-build/builds>`_

.. code-block:: shell

    cd ~/rcc-apps
    gcloud builds submit . --config=wrf/cloudbuild.yaml --project=<YOUR_PROJECT> --async


Once the build process is finished, you will have a VM image in your Google Cloud project, defined by the image :code:`selfLink` of :code:`projects/<YOUR_PROJECT>/global/images/wrf-gcp-foss-latest`. You can then use this image to deploy a RCC cluster that has WRF pre-installed.

Deploy the compute resources
=============================
To deploy the RCC cluster using the image you just created, you can use the example Terraform infrastructure-as-code scripts included under the :code:`wrf/tf/` directory in the RCC-Apps repository.

1. From your cloud shell, navigate to :code:`rcc-apps/wrf/tf` directory
   
.. code-block:: shell

    cd ~/rcc-apps/wrf/tf


2. Set the following environment variables to customize your deployment

   * :code:`WRF_NAME` (default : "wrf-demo") - The name of your deployment. This name prefixes your controller and login node instances for your cluster.
   * :code:`WRF_PROJECT` - The GCP project ID you want to deploy your cluster to. This environment variable must be set.
   * :code:`WRF_ZONE` (default : "us-west1-b") - The GCP Zone to deploy the cluster to
   * :code:`WRF_MACHINE_TYPE` (default : "c2-standard-8") - The GCE Instance type you want to use for compute nodes that will run WRF
   * :code:`WRF_MAX_NODE` (default : 3) - The maximum number of GCE instances available in your slurm partition for running WRF.
   * :code:`WRF_IMAGE` - The VM image to use to run WRF. Set this to :code:`projects/<YOUR_PROJECT>/global/images/wrf-gcp-foss-latest`

  As an example

.. code-block:: shell

    export WRF_IMAGE = projects/research-computing-cloud/global/images/wrf-gcp-foss-latest
    export WRF_NAME = rcc-wrf
    export WRF_MACHINE_TYPE = c2-standard-60
    export WRF_MAX_NODE = 20



3. Make the terraform plan. We've provided a Makefile that will concretize a Terraform tfvars file for this deployment based on the environment variables above and then create a Terraform plan. This makes the plan creation as simple as running :code:`make plan`. Once you've created the plan, you should review the list of resources that will be created before proceeding.
   
.. code-block:: shell

    make plan

4. Deploy the solution

.. code-block:: shell

   make apply


Once your cluster has been deployed, you can SSH into it and run WRF simulations.


===================
Further Reading
===================

* `Run the WRF CONUS Benchmarks with your RCC cluster <https://research-computing-cluster.readthedocs.io/en/latest/Tutorials/run_wrf_benchmarks.html>`_
