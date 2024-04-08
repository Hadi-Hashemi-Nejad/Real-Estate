#Creating an AWS S3 Bucket to be used as a data lake
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "hadis-s3-project-bucket"
  force_destroy = true

  tags = {
    Name        = "s3_bucket"
    Environment = "Dev"
  }
}

#Enabling bucket versioning to preserve, retrieve and restore data changes
resource "aws_s3_bucket_versioning" "s3_versioning_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#Creating folders and subfolders in S3 Bucket which inherit the bucket's encryption rules
resource "aws_s3_object" "s3-RealEstate-folder" {
  key                    = "Real-Estate/"
  bucket                 = aws_s3_bucket.s3_bucket.id
  server_side_encryption = "aws:kms"
}
resource "aws_s3_object" "s3-RealEstate-input-folder" {
  key                    = "Real-Estate/input/"
  bucket                 = aws_s3_bucket.s3_bucket.id
  server_side_encryption = "aws:kms"
}
resource "aws_s3_object" "s3-RealEstate-logs-folder" {
  key                    = "Real-Estate/logs/"
  bucket                 = aws_s3_bucket.s3_bucket.id
  server_side_encryption = "aws:kms"
}
resource "aws_s3_object" "s3-RealEstate-output-folder" {
  key                    = "Real-Estate/output/"
  bucket                 = aws_s3_bucket.s3_bucket.id
  server_side_encryption = "aws:kms"
}