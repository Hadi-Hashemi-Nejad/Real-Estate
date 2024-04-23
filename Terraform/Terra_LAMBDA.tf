data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iamRole_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# variable "env_name" {
#   description = "Environment Name"
# }

# data "aws_ecr_repository" "ingestion_ecr_repo" {
#   name = "public.ecr.aws/g4j2y3f2/bayut-ingestion-image:latest"
# }

# data "aws_ecr_image" "ingestion_image" {
#   repository_name = "my_ecr_repo"
#   image_tag       = "latest"
# }


resource "aws_lambda_function" "bayut_lambda_ingestion" {
  # function_name = "bayut-ingestion-image-${var.env_name}"
  function_name = "bayut-ingestion-image"
  timeout       = 300 # seconds
  # image_uri     = "${data.aws_ecr_image.ingestion_image.image_uri}:latest"
  # source_code_hash = trimprefix(data.aws_ecr_image.ingestion_image.id, "sha256:")
  image_uri     = "${aws_ecr_repository.my_ecr.repository_url}:latest"
  # image_uri     = "${data.aws_ecr_repository.ingestion_ecr_repo.repository_url}:${var.env_name}"
  package_type  = "Image"

  role = aws_iam_role.iam_for_lambda.arn

  # environment {
  #   variables = {
  #     ENVIRONMENT = var.env_name
  #   }
  # }
}

# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "${path.module}/../Ingestion/main.py"
#   output_path = "${path.module}/../Ingestion/main.zip"
# }

# resource "aws_lambda_function" "my_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   filename      = data.archive_file.lambda.output_path
#   function_name = "bayut_ingestions"
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
#     command = "sudo python3 -m pip install -r ../requirements.txt -t ${path.module}/layer/python --platform manylinux2014_aarch64 --implementation cp --only-binary=:all: --upgrade"
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
