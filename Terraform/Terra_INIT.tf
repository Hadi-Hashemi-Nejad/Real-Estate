#Initializes AWS as the cloud provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

#Assigns AWS credentials
provider "aws" {
  region = "us-east-1"
  access_key = var.AWS-credentials[0]
  secret_key = var.AWS-credentials[1]
}

#The variables used when assigning AWS credentials
variable "AWS-credentials" {
    description = "Access_key and secret_key to connect to AWS account"
}
