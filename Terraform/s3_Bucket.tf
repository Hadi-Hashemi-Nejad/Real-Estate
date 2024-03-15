#Creating an s3 Bucket to be used as a data lake
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "hadis-s3-project-bucket"

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