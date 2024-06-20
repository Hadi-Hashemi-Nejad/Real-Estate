# Dubai Distress Property Deal Finder - Work in Progress
## Requirements
- Terraform installation and configuration (https://www.youtube.com/watch?v=SLB_c_ayRMo&t=1211s&ab_channel=freeCodeCamp.org)
- Git installation
- Python installation and upgrade
- Pip installation and upgrade
- AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Docker (https://docs.docker.com/desktop/install/windows-install/)
## Steps
- create a workspace and change directory to that workspace in terminal
- `git clone https://github.com/Hadi-Hashemi-Nejad/Real-Estate`
- `cd /Real-Estate/Terraform`
- `terraform init`
- `echo "AWS-credentials = ["<your access key>", "<your secret_key>"]" >> terraform.tfvars` where ***\<your access key\>*** and ***\<your secret_key\>*** are the keys you retieve from your AWS account.
- `echo "unique_s3_name = "<a unique name for your s3 storage>"" >> terraform.tfvars` where ***\<a unique name for your s3 storage\>*** is any unique name for your s3 storage
- `terraform apply --auto-approve`
## Terraform
### Initialize
Terraform is used to create the AWS infastructure for this project. To run terraform users need to download and go through terraform's installation steps. And Remember to change directory to ***./Terraform*** when performing terraform actions in terminal. The ***./Terraform/Terra_INIT.tf*** file is used to initalize AWS. Users would need to retrieve their AWS account's credentials from the AWS website. Then save it in a ***./Terraform/terraform.tfvars*** appropriately by writing `AWS-credentials = ["<your access key>", "<your secret_key>"]`. 
### S3 Buckets
The ***./Terraform/Terra_S3.tf*** file is used to create the AWS S3 bucket which will be used as a data lake in this project. The bucket versioning is turned on using the `aws_s3_bucket_versioning` resource. This keeps different versions of the objects in the bucket and helps recover unintended actions. It may be benefical to turn this off in order to reduce costs if S3 costs are far too high. The resource `aws_s3_object` creates the folders and subfolders for the bucket.
### VPC (Do I need this?)
A VPC (Virtual Private Cloud) is created within ***./Terraform/Terra_VPC.tf*** to customize how the AWS services connect to one another and to the outside world. Within the VPC, a single public subnet is created that is open to the internet via an internet gateway. The resource `aws_security_group` is defined for the VPC which allowed all ports to recieve and send anything. This is not a safe practice and may need to be changed later. Resources `aws_network_interface` and `aws_eip` are also created to provide an ip address to connect to the instances being created.
### ECR
An ECR (Elastic Container Registery) is created in ***./Terraform/Terra_ECR.tf*** to hold docker images used in the lambda functions. The `aws_ecr_repository` resource creates a private registry and docker images from  ***./Terraform/Images*** are built / pushed to the registry using the `local-exec` provisioner. This will allow lambda to run python scripts sucessfully using docker containers of the images pushed.
### Lambda
Lambda functions are created in ***./Terraform/Terra_LAMBDA.tf*** to ingest Bayut's property listings from ***https://rapidapi.com/apidojo/api/bayut*** & Dubai Land Department's (DLD) historical transactions from ***https://www.dubaipulse.gov.ae/data/dld-transactions/dld_transactions-open*** and then upload them to the S3 bucket. AWS Lambda is a serverless cloud computing service that will allow us to only be running servers when python scripts are be scheduled to run and thus reduce costs. Two seperate functions are made for each ingestion job and each use their respective images created and uploaded to ECR. Please beware that the DLD transaction files are about 50 mb each and thus take several minutes for the lambda function to run.
### EMR
An EMR (Elastic Map Reduce) cluster is created in ***./Terraform/Terra_EMR.tf*** to use a cluster of EC2 instances to run pyspark. This will allow us to scale our applications both veritically and horizontally. IAM roles are also created and assigned since EMR requires IAM roles. To connect to this cluster you'd need to download a pem key pair from AWS websiteand call it `main-access-key-pair.pem`. Place it in user/your_user_name and call: `terraform output emr_ip_address` to find the emr's ip address. Place it in `ssh -i ~/main-access-key-pair.pem hadoop@<the ip address without quotes>` to ssh into your cluster.

Hadi: use ctrl+shift+v when editing this.