variable "fn_name" {
  type = string
}

variable "http_method" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_build" {
  type = string
}

variable "artifacts_bucket" {
  type    = string
  default = "lambda-artifacts-bb"
}

variable "apigw_id" {
  type = string
}

variable "root_resource_id" {
  type = string
}

variable "apigw_execution_arn" {
  type = string
}