# Dubai Distress Property Deal Finder
## Requirements
- Terraform installation and configuration (https://www.youtube.com/watch?v=SLB_c_ayRMo&t=1211s&ab_channel=freeCodeCamp.org)
- Git installation
- Python installation and upgrade
- Pip installation and upgrade
## Steps
- create a workspace and change directory to that workspace in terminal
- `git clone https://github.com/Hadi-Hashemi-Nejad/Real-Estate`
- `cd /Real-Estate/Terraform`
- `terraform init`
- create layer\python?
- 
## Terraform
### Initialize
Terraform is used to create the AWS infastructure for this project. To run terraform users need to download and go through terraform's installation steps. And Remember to change directory to ***./Terraform*** when performing terraform actions in terminal. The ***./Terraform/Terra_INIT.tf*** file is used to initalize AWS. Users would need to retrieve their AWS account's credentials from the AWS website. Then save it in a ***./Terraform/terraform.tfvars*** appropriately by writing `AWS-credentials = ["<your access key>", "<your secret_key>"]`. 
### S3 Buckets
The ***./Terraform/Terra_S3.tf*** file is used to create the AWS S3 bucket which will be used as a data lake in this project. The bucket versioning is turned on using the `aws_s3_bucket_versioning` resource. This keeps different versions of the objects in the bucket and helps recover unintended actions. It may be benefical to turn this off in order to reduce costs if S3 costs are far too high. The resource `aws_s3_object` creates the folders and subfolders for the bucket.
### VPC
A VPC (Virtual Private Cloud) is created within ***./Terraform/Terra_VPC.tf*** to customize how the AWS services connect to one another and to the outside world. Within the VPC, a single public subnet is created that is open to the internet via an internet gateway. The resource `aws_security_group` is defined for the VPC which allowed all ports to recieve and send anything. This is not a safe practice and may need to be changed later. Resources `aws_network_interface` and `aws_eip` are also created to provide an ip address to connect to the instances being created.
### EMR
An EMR (Elastic Map Reduce) cluster is created in ***./Terraform/Terra_EMR.tf*** to use a cluster of EC2 instances to run pyspark. This will allow us to scale our applications both veritically and horizontally. IAM roles are also created and assigned since EMR requires IAM roles. To connect to this cluster you'd need to download a pem key pair from AWS websiteand call it `main-key.pem`. Place it in your working directory and call: `terraform output emr_ip_address` to find the emr's ip adress. Place it in `ssh -i "main-key.pem" ec2-user@<the ip address without quotes>` to ssh into your cluster.

Hadi: use ctrl+shift+v when editing this.