WRF_NAME ?= "wrf-demo"
WRF_PROJECT ?= ""
WRF_ZONE ?= "us-west1-b"
WRF_MACHINE_TYPE ?= "c2-standard-8"
WRF_MAX_NODE ?= 3
WRF_IMAGE ?= "projects/hpc-apps/global/images/wrf-gcp-slurm-gcp-centos7-latest"

.PHONY: plan apply destroy

fluid.tfvars: fluid.tfvars.tmpl
	cp fluid.tfvars.tmpl fluid.tfvars
	sed -i "s/<cluster name>/${WRF_NAME}/g" fluid.tfvars
	sed -i "s/<project>/${WRF_PROJECT}/g" fluid.tfvars
	sed -i "s/<zone>/${WRF_ZONE}/g" fluid.tfvars
	sed -i "s/<machine_type>/${WRF_MACHINE_TYPE}/g" fluid.tfvars
	sed -i "s/<max_node>/${WRF_MAX_NODE}/g" fluid.tfvars
	sed -i "s#<image>#${WRF_IMAGE}#g" fluid.tfvars

.terraform: 
	terraform init

plan: fluid.tfvars .terraform
	terraform plan -var-file=fluid.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=fluid.tfvars -auto-approve

destroy:
	terraform destroy -var-file=fluid.tfvars -auto-approve
