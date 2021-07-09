FOAM_NAME ?= "openfoam"
FOAM_PROJECT ?= ""
FOAM_ZONE ?= "us-west1-b"
FOAM_MACHINE_TYPE ?= "c2-standard-60"
PARAVIEW_MACHINE_TYPE ?= "n2-standard-80"
FOAM_MAX_NODE ?= 5
PARAVIEW_MAX_NODE ?= 5
FOAM_IMAGE ?= "projects/hpc-apps/global/images/fluid-hpc-openfoam-gcc-10-ompi-4-2f78318"

.PHONY: plan apply destroy

fluid.tfvars: fluid.tfvars.tmpl
	cp fluid.tfvars.tmpl fluid.tfvars
	sed -i "s/<cluster name>/${FOAM_NAME}/g" fluid.tfvars
	sed -i "s/<project>/${FOAM_PROJECT}/g" fluid.tfvars
	sed -i "s/<zone>/${FOAM_ZONE}/g" fluid.tfvars
	sed -i "s/<foam_machine_type>/${FOAM_MACHINE_TYPE}/g" fluid.tfvars
	sed -i "s/<paraview_machine_type>/${PARAVIEW_MACHINE_TYPE}/g" fluid.tfvars
	sed -i "s/<foam_max_node>/${FOAM_MAX_NODE}/g" fluid.tfvars
	sed -i "s/<paraview_max_node>/${PARAVIEW_MAX_NODE}/g" fluid.tfvars
	sed -i "s#<image>#${FOAM_IMAGE}#g" fluid.tfvars

.terraform: 
	terraform init

plan: fluid.tfvars .terraform
	terraform plan -var-file=fluid.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=fluid.tfvars -auto-approve

destroy:
	terraform destroy -var-file=fluid.tfvars -auto-approve
