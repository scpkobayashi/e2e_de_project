####################################################################################################################
# Set up cloud infrastructure 


infra-up:
	bash -c "source azure_sp_setup.sh && \
		terraform -chdir=./terraform init --upgrade && \
		terraform -chdir=./terraform validate && \
		terraform -chdir=./terraform plan -out=tfplan && \
		terraform -chdir=./terraform apply -auto-approve tfplan &&\
		terraform -chdir=./terraform output -raw private_key > ~/.ssh/myKey.pem &&\
		chmod 400 ~/.ssh/myKey.pem"

infra-down:
	terraform -chdir=./terraform destroy -auto-approve
