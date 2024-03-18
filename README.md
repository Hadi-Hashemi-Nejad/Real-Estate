# Real-Estate

## Terraform
Terraform is used to create the AWS infastructure for this project. To run terraform users need to download and go through terraform's installation steps. And Remember to change directory to ***./Terraform*** when performing terraform actions in terminal. The ***./Terraform/Provider.tf*** file is used to initalize AWS. Users would need to retrieve their AWS account's credentials from the AWS website. Then save it in a ***./Terraform/terraform.tfstate*** appropriately by writing `AWS-credentials = [<your access key>, <your secret_key>]`or manually enter it after initalizing terraform by `terraform init`. 

The ***./Terraform/S3_Bucket.tf*** file is used to create the AWS S3 bucket which will be used as a data lake in this project. The bucket versioning is turned on using the `aws_s3_bucket_versioning` resource. This keeps different versions of the objects in the bucket and helps recover unintended actions. It may be benefical to turn this off in order to reduce costs if S3 costs are far too high. The resource `aws_s3_object` creates the folders and subfolders for the bucket.

A VPC (Virtual Private Cloud) is created within ***./Terraform/VPC.tf*** to customize how the AWS services connect to one another and to the outside world. Within the VPC, a single public subnet is created that is open to the internet via an internet gateway.

Hadi: use ctrl+shift+v when editing this