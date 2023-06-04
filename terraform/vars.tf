variable "vpc_id" {
  default = "vpc-be6799da"
}

variable "artifacts_bucket" {
  type    = string
  default = "lambda-artifacts-bb"
}

variable "tfc_secret_arn" {
  type    = string
  default = "arn:aws:secretsmanager:us-east-1:261220833951:secret:tfc_token-hUk0Xy"
}

variable "tfc_url" {
  type    = string
  default = "https://app.terraform.io"
}

variable "tfc_org" {
  type    = string
  default = "tba_bb"
}

variable "workspace_id" {
  type    = string
  default = "ws-3c8reuKc6dqa5FjC"
}

variable "customers" {
  type = list(string)
  default = ["marriott","hilton","star"]
}