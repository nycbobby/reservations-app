module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  vpc_id          = var.vpc_id
}

module "apigw" {
  source          = "./modules/apigw"
  apigw_name      = var.apigw_name
  lambda_role_arn = module.iam.reservations_lambda_role_arn
  apigw_resources = var.apigw_resources
}

module "customer_tables" {
  source   = "./modules/dynamo_table"
  for_each = toset(var.customers)
  customer = each.key
}

module "iam" {
  source         = "./modules/iam"
  tfc_secret_arn = var.tfc_secret_arn
  cluster_name   = var.cluster_name
}

module "standby_lambdas" {
  source           = "./modules/lambda"
  for_each         = var.standby_lambdas
  fn_name          = each.key
  lambda_build     = each.value["build"]
  schedule         = each.value["schedule"]
  artifacts_bucket = var.artifacts_bucket
  lambda_role_arn  = module.iam.standby_lambda_role_arn

  environment_vars = {
    CLUSTER_NAME   = var.cluster_name
    NODEGROUP_NAME = var.node_group_name
  }
}

resource "aws_ecr_repository" "demo" {
  name                 = "demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

