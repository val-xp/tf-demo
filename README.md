# tf-demo
Terraform Databricks workspace demo

## Pre requisites
- azure cli
- terraform

Login in Azure:

> az login
 
Select subscription  
  
> az account set --subscription "your subscription id here" 

## Usage

Initialize the project:
> terraform init

See the deployment plan:
> terraofrm plan

Deploy the resouces:
> terraform apply

Destroy the resouces:
> terraform destroy
