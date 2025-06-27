variable "vpc_id" {
  default = "vpc-be6799da"
}

variable "artifacts_bucket" {
  description = "bucket for codedeploy to use for storing lambda zip files."
  type        = string
  default     = "lambda-artifacts-bb"
}

variable "tfc_secret_arn" {
  description = "secrets manager arn for terraform cloud authentication secret."
  type        = string
  default     = "arn:aws:secretsmanager:us-east-1:261220833951:secret:tfc_token-hUk0Xy"
}

variable "tfc_url" {
  description = "terraform cloud url."
  type        = string
  default     = "https://app.terraform.io"
}

variable "tfc_org" {
  description = "terraform cloud organization name."
  type        = string
  default     = "tba_bb"
}

variable "workspace_id" {
  type    = string
  default = "ws-3c8reuKc6dqa5FjC"
}

variable "customers" {
  type    = list(string)
  default = ["marriott", "hilton", "star"]
}

variable "cluster_name" {
  type    = string
  default = "eks_test"
}

variable "node_group_name" {
  descriptiop = "eks node group name, for nginx deployment."
  type        = string
  default     = "eks_test_nodegroup"
}

variable "apigw_name" {
  type    = string
  default = "reservations"
}

variable "apigw_resources" {
  description = "api gateway resources names with their corresponding methods and lambdas build numbers."
  type        = list(list(string))

  # format ["fn_name","http_method","lambda_build"]
  default = [
    ["get-res", "GET", "65"],
    ["add-res", "POST", "64"],
    ["delete-res", "POST", "66"]
  ]

}

variable "standby_lambdas" {
  description = "schedule for tearing down and deploying EKS cluster."
  type        = map(any)
  default     = {
    "eks-delete-cluster" = {
      "build" = "52"
      "schedule" = {
        "midnight" = "cron(0 4 * * ? *)",
        "9am"      = "cron(0 13 * * ? *)",
        "3pm"      = "cron(0 19 * * ? *)"
      }
    }
    "eks-deploy-cluster" = {
      "build" = "49"
      "schedule" = {
        "6am"  = "cron(0 10 * * ? *)",
        "11am" = "cron(0 15 * * ? *)",
        "6pm"  = "cron(0 22 * * ? *)"
      }
    }
  }
}
