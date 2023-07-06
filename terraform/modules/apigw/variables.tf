variable "apigw_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "apigw_resources" {
  type = list(list(string))
}