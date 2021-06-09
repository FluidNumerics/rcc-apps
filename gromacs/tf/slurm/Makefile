WRF_NAME ?= "wrf-demo"
WRF_PROJECT ?= ""
WRF_ZONE ?= "us-west1-b"
WRF_MACHINE_TYPE ?= "c2-standard-8"
WRF_MAX_NODE ?= 3

.PHONY: plan apply destroy

basic.tfvars: basic.tfvars.tmpl
	cp basic.tfvars.tmpl basic.tfvars
	sed -i "s/<cluster name>/${WRF_NAME}/g" basic.tfvars
	sed -i "s/<project>/${WRF_PROJECT}/g" basic.tfvars
	sed -i "s/<zone>/${WRF_ZONE}/g" basic.tfvars
	sed -i "s/<machine_type>/${WRF_MACHINE_TYPE}/g" basic.tfvars
	sed -i "s/<max_node>/${WRF_MAX_NODE}/g" basic.tfvars

plan: basic.tfvars
	terraform plan -var-file=basic.tfvars -out terraform.tfplan

apply: plan
	terraform apply -var-file=basic.tfvars -auto-approve

destroy:
	terraform destroy -var-file=basic.tfvars -auto-approve
