RCC_NAME ?= "rcc-demo"
RCC_PROJECT ?= ""
RCC_ZONE ?= "us-west1-b"
RCC_MACHINE_TYPE ?= "c2-standard-8"
RCC_IMAGE ?= "projects/research-computing-cloud/global/images/family/wrf-intel-cascadelake"
RCC_MAX_NODE ?= 3

.PHONY: init plan apply destroy

basic.tfvars: basic.tfvars.tmpl
	cp basic.tfvars.tmpl basic.tfvars
	sed -i "s/<cluster name>/${RCC_NAME}/g" basic.tfvars
	sed -i "s/<project>/${RCC_PROJECT}/g" basic.tfvars
	sed -i "s/<zone>/${RCC_ZONE}/g" basic.tfvars
	sed -i "s/<machine_type>/${RCC_MACHINE_TYPE}/g" basic.tfvars
	sed -i "s/<max_node>/${RCC_MAX_NODE}/g" basic.tfvars
	sed -i "s#<image>#${RCC_IMAGE}#g" basic.tfvars

init: 
	terraform init

plan: init basic.tfvars
	terraform plan -var-file=basic.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=basic.tfvars -auto-approve

destroy:
	terraform destroy -var-file=basic.tfvars -auto-approve
