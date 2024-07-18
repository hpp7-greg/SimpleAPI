# Terraform Project for a Simple API

## Use Case:
The purpose of this exercise is to create a single module that deploys independent resources (i.e., if you call the same module twice in your root, there should be no conflicts based on the module inputs)
 
Create a system which will return the current time and the IP address of the requestor. The system should only be publicly accessible via a public API endpoint. The system should only return the required data for GET requests. All other request methods should result in some sort of error.
 
You should use an API Gateway and a Lambda function running the python runtime. Your module should deploy and configure all resources required (Log groups, IAM, etc.)

## Statefile:
s3 backed statefile created prior to terraform up

Bucket Name: simple-api-tf-state

## Deployment:

terraform plan -var-file="./../../environments/dev.tfvars"