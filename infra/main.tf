provider "aws" {
  region = "us-east-1"
  profile = "default"
}

#S3 bucket
resource "aws_s3_bucket" "images-bucket" {
    bucket = "camesruiz-stori-images"
}

resource "aws_s3_bucket" "thumbnails-bucket" {
    bucket = "camesruiz-stori-thumbnails"
}

resource "aws_s3_object" "origin-folder" {
    bucket = "${aws_s3_bucket.images-bucket.id}"
    key    = "original/"
}


resource "aws_s3_bucket" "lambda-bucket" {
    bucket = "stori-lambda-artifacts"
}

#IAM Role
resource "aws_iam_policy" "s3_policy" {
  name        = "S3"
  description = "Access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::*/*"
      ]
    }]
  })
}

resource "aws_iam_role" "s3_role" {
  name = "stori_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# lambda function
resource "aws_lambda_function" "lambda-function" {
  function_name = "thumbnail_gen"
  role          = aws_iam_role.s3_role.arn
  s3_bucket     = aws_s3_bucket.lambda-bucket.bucket
  s3_key        = "lambda_function.zip"
  handler       = "main.lambda.handler"
  runtime       = "python3.8"
}