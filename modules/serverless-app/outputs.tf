output "base_invoke_url" {
  description = "The base URL for the API stage (e.g., https://.../v1)."
  value = aws_api_gateway_stage.this.invoke_url
}

output "full_endpoint" {
  description = "The full, invokable URL for the deployed API endpoint."
  value = "${aws_api_gateway_stage.this.invoke_url}/${var.api_path}"
}

output "lambda_fn_arn" {
  description = "The ARN of the created Lambda function."
  value = aws_lambda_function.this.arn
}

output "api_gw_id" {
  description = "The ID of the created REST API."
  value = aws_api_gateway_rest_api.this.id
}

output "aws_api_gateway_execution_arn" {
  description = "The execution ARN of the REST API, used for building Lambda permissions."
  value = aws_api_gateway_rest_api.this.execution_arn
}