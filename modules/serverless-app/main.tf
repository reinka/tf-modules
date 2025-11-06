data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = var.lambda_source_path
  output_path = "${path.module}/lambda_function_payload.zip"
}

# iam

data "aws_iam_policy_document" "lambda_exec_role" {
  statement {
    actions = [ "sts:AssumeRole" ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
    name = "${var.project_name}-lambda-exec-role"
    assume_role_policy = data.aws_iam_policy_document.lambda_exec_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# s3

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-bucket-${random_id.bucket_suffix.hex}"
}

locals {
  lambda_bucket_key = basename(data.archive_file.lambda_zip.output_path)
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key = local.lambda_bucket_key
  source = data.archive_file.lambda_zip.output_path
  etag = data.archive_file.lambda_zip.output_md5
}

# lambda

resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}-func"
  handler = var.handler_name
  runtime = var.lambda_runtime
  role = aws_iam_role.lambda_exec_role.arn
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = local.lambda_bucket_key
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout = 10
}

# API GW

resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-api"
  description = "TF deployed lambda API"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = var.api_path
}

resource "aws_api_gateway_method" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  type = "AWS_PROXY"
  http_method = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  uri = aws_lambda_function.this.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.this,
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = data.archive_file.lambda_zip.output_base64sha256
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "v1"
}