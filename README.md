# Real-Estate

## Terraform
Terraform is used to create the AWS infastructure for this project. Remember to change directory to ***./Terraform*** when performing terraform actions in terminal. The ***./Terraform/Provider.tf*** file is used to initalize AWS. A user would need to retrieve their AWS account's credentials from the AWS website. Then save it in a ***./Terraform/terraform.tfstate*** appropriately `AWS-credentials = [<access key>, <secret_key>]`or manually enter it after initalizing terraform by `terraform init`. 

The ***./Terraform/s3_Bucket.tf*** file is used to create the AWS s3 bucket which will be used as a data lake in this project. The bucket versioning is turned on using the `aws_s3_bucket_versioning` resource. This keeps different versions of the objects in the bucket and helps recover unintended actions. It may be benefical to turn this off in order to reduce costs if s3 costs are far too high. And the `aws_s3_object` creates the folders and subfolders for the bucket.

Hadi: use ctrl+shift+v when editing this