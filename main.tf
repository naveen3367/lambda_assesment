# Configure AWS provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for Lambda Function
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_basic_execution_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:/aws/lambda/${aws_lambda_function.lambda_function.arn}:*"
      ]
    }
  ]
}
EOF
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create Lambda Function from Python Code
resource "aws_lambda_function" "lambda_function" {
  filename         = var.filename #"lambda_function.py.zip"
  function_name    = var.function_name #"testing123"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip_file.output_path)
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"

  memory_size = 128
  timeout     = 60
}

/* LAMBDA FUNCTION */
data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "./lambda_function.py"
  output_path = "./lambda_function.py.zip"
}

variable "filename" {
  type = string
  description = "File name of the lambda function"
}

variable "function_name" {
  type = string
  description = "function_name of the lambda"
}