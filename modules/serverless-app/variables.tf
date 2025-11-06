variable "project_name" {
  type = string
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type = string
  default = "python3.11"
}


variable "handler_name" {
  description = "The function entry point in the format: <file>.<function>"
  type = string
  default = "handler.lambda_handler"
}

variable "lambda_source_path" {
  description = "The absolute or relative path to the source code file (e.g., ../lambda_handler.py)"
  type        = string
}

variable "api_path" {
  description = "The path part for the API Gateway resource (e.g., 'hello' for /hello)"
  type        = string
  default     = "hello"
}