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

#IAM Role S3
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
  layers        = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p38-Pillow:10"]
  role          = aws_iam_role.s3_role.arn
  s3_bucket     = aws_s3_bucket.lambda-bucket.bucket
  s3_key        = "lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
}

# IAM Role API Gateway

resource "aws_iam_policy" "api_policy" {
  name        = "api_gateway_s3"
  description = "Connect API to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::camesruiz-stori-images/original"
      ]
    }]
  })
}

resource "aws_iam_role" "api_role" {
  name = "api_gateway_s3_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_access_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}