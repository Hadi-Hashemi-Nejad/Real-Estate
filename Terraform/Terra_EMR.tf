# #Creating a spark cluster with one master instance and 3 worker instances
# resource "aws_emr_cluster" "spark_cluster" {
#   name          = "spark_emr"
#   release_label = "emr-7.0.0"
#   applications  = ["Spark"]

#   ec2_attributes {
#     subnet_id                         = aws_subnet.main_subnet.id
#     emr_managed_master_security_group = aws_security_group.allow_traffic.id
#     emr_managed_slave_security_group  = aws_security_group.allow_traffic.id
#     instance_profile                  = aws_iam_instance_profile.emr_profile.arn
#     key_name                          = "main-key"
#   }

#   master_instance_group {
#     instance_type = "m4.large"
#   }

#   core_instance_group {
#     instance_count = 3
#     instance_type  = "c4.large"
#   }

#   auto_termination_policy {
#     idle_timeout = 3600
#   }

#   # Rename this to the logs folder in your s3 bucket. Can be found on AWS website
#   log_uri = "s3://hadis-s3-project-bucket/Real-Estate/logs/" 

#   service_role = aws_iam_role.iam_emr_service_role.arn
# }

# output "emr_ip_address" {
#   value = aws_emr_cluster.spark_cluster.master_public_dns
# }

# ###

# # IAM Role setups

# ###

# # IAM role for EMR Service
# data "aws_iam_policy_document" "emr_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["elasticmapreduce.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }
# resource "aws_iam_role" "iam_emr_service_role" {
#   name               = "iam_emr_service_role"
#   assume_role_policy = data.aws_iam_policy_document.emr_assume_role.json
# }
# data "aws_iam_policy_document" "iam_emr_service_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "ec2:*",
#       "iam:GetRole",
#       "iam:GetRolePolicy",
#       "iam:ListInstanceProfiles",
#       "iam:ListRolePolicies",
#       "iam:PassRole",
#       "s3:CreateBucket",
#       "s3:Get*",
#       "s3:List*",
#       "sdb:BatchPutAttributes",
#       "sdb:Select",
#       "sqs:CreateQueue",
#       "sqs:Delete*",
#       "sqs:GetQueue*",
#       "sqs:PurgeQueue",
#       "sqs:ReceiveMessage",
#     ]

#     resources = ["*"]
#   }
# }
# resource "aws_iam_role_policy" "iam_emr_service_policy" {
#   name   = "iam_emr_service_policy"
#   role   = aws_iam_role.iam_emr_service_role.id
#   policy = data.aws_iam_policy_document.iam_emr_service_policy.json
# }

# # IAM Role for EC2 Instance Profile
# data "aws_iam_policy_document" "ec2_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }
# resource "aws_iam_role" "iam_emr_profile_role" {
#   name               = "iam_emr_profile_role"
#   assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
# }
# resource "aws_iam_instance_profile" "emr_profile" {
#   name = "emr_profile"
#   role = aws_iam_role.iam_emr_profile_role.name
# }
# data "aws_iam_policy_document" "iam_emr_profile_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "cloudwatch:*",
#       "dynamodb:*",
#       "ec2:Describe*",
#       "elasticmapreduce:Describe*",
#       "elasticmapreduce:ListBootstrapActions",
#       "elasticmapreduce:ListClusters",
#       "elasticmapreduce:ListInstanceGroups",
#       "elasticmapreduce:ListInstances",
#       "elasticmapreduce:ListSteps",
#       "kinesis:CreateStream",
#       "kinesis:DeleteStream",
#       "kinesis:DescribeStream",
#       "kinesis:GetRecords",
#       "kinesis:GetShardIterator",
#       "kinesis:MergeShards",
#       "kinesis:PutRecord",
#       "kinesis:SplitShard",
#       "rds:Describe*",
#       "s3:*",
#       "sdb:*",
#       "sns:*",
#       "sqs:*",
#     ]

#     resources = ["*"]
#   }
# }
# resource "aws_iam_role_policy" "iam_emr_profile_policy" {
#   name   = "iam_emr_profile_policy"
#   role   = aws_iam_role.iam_emr_profile_role.id
#   policy = data.aws_iam_policy_document.iam_emr_profile_policy.json
# }