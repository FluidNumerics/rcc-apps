HPC_NAME ?= "wrf-demo"
HPC_PROJECT ?= ""
HPC_ZONE ?= "us-west1-b"
HPC_MACHINE_TYPE ?= "c2-standard-8"
HPC_MAX_NODE ?= 3
HPC_IMAGE ?= "projects/${HPC_PROJECT}/global/images/hpc-benchmarks-foss-latest"

.PHONY: plan apply destroy

fluid.tfvars: fluid.tfvars.tmpl
	cp fluid.tfvars.tmpl fluid.tfvars
	sed -i "s/<cluster name>/${HPC_NAME}/g" fluid.tfvars
	sed -i "s/<project>/${HPC_PROJECT}/g" fluid.tfvars
	sed -i "s/<zone>/${HPC_ZONE}/g" fluid.tfvars
	sed -i "s/<machine_type>/${HPC_MACHINE_TYPE}/g" fluid.tfvars
	sed -i "s/<max_node>/${HPC_MAX_NODE}/g" fluid.tfvars
	sed -i "s#<image>#${HPC_IMAGE}#g" fluid.tfvars

.terraform: 
	terraform init

plan: fluid.tfvars .terraform
	terraform plan -var-file=fluid.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=fluid.tfvars -auto-approve

destroy:
	terraform destroy -var-file=fluid.tfvars -auto-approve
