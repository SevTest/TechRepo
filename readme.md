# Pre-requisites for deployment
Install Git for your operating system
https://git-scm.com/download/win

# Install VS code
https://code.visualstudio.com/

Install Terraform Module (As this is common platform used by all cloud providers)

# Create tf files for IaC deployments
main.tf  
variables.tf  
variables.tfvars

# Clone Git Repo
git checkout master - clone the repo  
git clone https://github.com/servian/TechChallengeApp.git  
git checkout -b features/golanappiacdeployment  

git add .  
git commit -m "ÏaC deployment added for docker and postgressql"  
git push  

do a PR and get it reviewed by peers

all ok then merge to master

# Assuming deploying to Azure 

az login  
az account set --subscription {subscription_id}

To Deploy resources in Azure Platform  
terraform init  
terraform plan  
terraform deploy
