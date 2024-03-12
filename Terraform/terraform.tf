#This initializes AWS as the cloud provider and asks for AWS credentials

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  access_key = var.AWS-credentials[0]
  secret_key = var.AWS-credentials[1]
}

variable "AWS-credentials" {
    description = "Access_key and secret_key to connect to AWS account"
}

