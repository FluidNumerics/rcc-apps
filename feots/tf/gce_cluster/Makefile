FEOTS_NAME ?= "feots"
FEOTS_PROJECT ?= $(shell gcloud config get-value project)
FEOTS_ZONE ?= "us-west1-b"
FEOTS_MACHINE_TYPE ?= "c2-standard-16"
FEOTS_NODE_COUNT ?= 1
FEOTS_IMAGE ?= "projects/hpc-apps/global/images/feots-gcp-foss-latest"

.PHONY: clean plan apply destroy

fluid.tfvars: fluid.tfvars.tmpl
	cp fluid.tfvars.tmpl fluid.tfvars
	sed -i "s/<name>/${FEOTS_NAME}/g" fluid.tfvars
	sed -i "s/<project>/${FEOTS_PROJECT}/g" fluid.tfvars
	sed -i "s/<zone>/${FEOTS_ZONE}/g" fluid.tfvars
	sed -i "s/<machine_type>/${FEOTS_MACHINE_TYPE}/g" fluid.tfvars
	sed -i "s/<node_count>/${FEOTS_NODE_COUNT}/g" fluid.tfvars
	sed -i "s#<image>#${FEOTS_IMAGE}#g" fluid.tfvars

.terraform: 
	terraform init

plan: fluid.tfvars .terraform
	terraform plan -var-file=fluid.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=fluid.tfvars -auto-approve

destroy:
	terraform destroy -var-file=fluid.tfvars -auto-approve
	rm fluid.tfvars

clean:
	rm -rf fluid.tfvars .terraform terraform.tfstate*


