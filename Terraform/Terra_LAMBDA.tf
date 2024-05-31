#IAM role for lambda functions
data "aws_iam_policy_document" "lambda_assume_role" {
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
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
resource "aws_iam_role_policy_attachment" "terraform_lambda_cloudwatch_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

#This lambda function uploads Bayut listings to S3 bucket using docker image uploaded on ECR
resource "aws_lambda_function" "bayut_lambda_ingestion" {
  function_name = "bayut-ingestion-function"
  timeout       = 300 # seconds
  image_uri     = "${aws_ecr_repository.my_ecr.repository_url}:${local.image_tag_bayut}"
  package_type  = "Image"
  role = aws_iam_role.iam_for_lambda.arn
}

#This lambda function uploads DLD transactions to S3 bucket using docker image uploaded on ECR
resource "aws_lambda_function" "DLD_lambda_ingestion" {
  /* BIG ALERT FOR ME -------------------------------------------------------------------------------------------------------------> 
lambda reruns the function after a minute into the get request. But runs are successful even though an error is given during test ///
*/
  function_name = "dld-ingestion-function"
  timeout       = 900 # seconds
  image_uri     = "${aws_ecr_repository.my_ecr.repository_url}:${local.image_tag_dld}"
  package_type  = "Image"
  role = aws_iam_role.iam_for_lambda.arn
  memory_size = 3008 # (MB) This was changed to the max since DLD file is very large
  ephemeral_storage {
    size = 10240 # (MB) This was changed to the max since DLD file is very large
  }
}