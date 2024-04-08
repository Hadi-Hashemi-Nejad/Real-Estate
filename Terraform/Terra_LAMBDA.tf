# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "iam_for_lambda"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "${path.module}/../Ingestion/main.py"
#   output_path = "${path.module}/../Ingestion/main.zip"
# }

# resource "aws_lambda_function" "my_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   filename      = data.archive_file.lambda.output_path
#   function_name = "bayut_ingestion"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "main.run"
#   source_code_hash = data.archive_file.lambda.output_base64sha256
#   layers           = [aws_lambda_layer_version.layer.arn]
#   runtime = "python3.8"
# }

# resource "null_resource" "pip_install" {
#   triggers = {
#     shell_hash = "${sha256(file("${path.module}/../requirements.txt"))}"
#   }

#   provisioner "local-exec" {
#     command = "python3 -m pip install -r ../requirements.txt -t ${path.module}/layer/python"
#   }
# }

# data "archive_file" "layer" {
#   type        = "zip"
#   source_dir  = "${path.module}/layer"
#   output_path = "${path.module}/layer.zip"
#   depends_on  = [null_resource.pip_install]
# }

# resource "aws_lambda_layer_version" "layer" {
#   layer_name          = "requirements-layer"
#   filename            = data.archive_file.layer.output_path
#   source_code_hash    = data.archive_file.layer.output_base64sha256
#   compatible_runtimes = ["python3.9", "python3.8", "python3.7", "python3.6"]
# }
