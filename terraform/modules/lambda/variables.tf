variable "fn_name" {
  type = string
}

variable "lambda_build" {
  type = string
}

variable "artifacts_bucket" {
  type = string
}

# variable "s3_key" {
#     type = string
# }

variable "lambda_role_arn" {
  type = string
}

variable "environment_vars" {
  type    = map(string)
  default = {}
}

variable "schedule" {
  type    = map(any)
  default = {}
}