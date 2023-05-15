module "del_eks_lambda" {
  source           = "./modules/lambda"
  fn_name          = "eks-delete-cluster"
  lambda_build     = "52"
  artifacts_bucket = var.artifacts_bucket
  lambda_role_arn  = aws_iam_role.delete_cluster_lambda.arn

  environment_vars = {
    CLUSTER_NAME   = var.cluster_name
    NODEGROUP_NAME = var.node_group_name
  }

}

module "deploy_eks_lambda" {
  source           = "./modules/lambda"
  fn_name          = "eks-deploy-cluster"
  lambda_build     = "49"
  artifacts_bucket = var.artifacts_bucket
  lambda_role_arn  = aws_iam_role.deploy_cluster_lambda.arn

  environment_vars = {
    TFC_URL      = var.tfc_url
    TFC_ORG      = var.tfc_org
    WORKSPACE_ID = var.workspace_id
  }

}

variable "delete_eks_sched" {
  type = map(string)
  default = {
    "midnight" = "cron(0 4 * * ? *)",
    "9am"      = "cron(0 13 * * ? *)",
    "3pm"      = "cron(0 19 * * ? *)"
  }
}

variable "deploy_eks_sched" {
  type = map(string)
  default = {
    "6am"  = "cron(0 10 * * ? *)",
    "11am" = "cron(0 15 * * ? *)",
    "6pm"  = "cron(0 22 * * ? *)"
  }
}

module "delete_eks_rules" {
  for_each            = var.delete_eks_sched
  source              = "./modules/event_rule"
  rule_name           = "delete-cluster-${each.key}"
  rule_desc           = "Daily at ${each.key}"
  lambda_arn          = module.del_eks_lambda.arn
  schedule_expression = each.value
}

module "deploy_eks_rules" {
  for_each            = var.deploy_eks_sched
  source              = "./modules/event_rule"
  rule_name           = "deploy-cluster-${each.key}"
  rule_desc           = "Daily at ${each.key}"
  lambda_arn          = module.deploy_eks_lambda.arn
  schedule_expression = each.value
}