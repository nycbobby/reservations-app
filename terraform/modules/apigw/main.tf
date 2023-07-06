locals {
  apigw_execution_arn = "${aws_api_gateway_rest_api.reservations.execution_arn}/*"
}

resource "aws_api_gateway_rest_api" "reservations" {
  name = var.apigw_name
}

resource "aws_api_gateway_deployment" "reservations" {
  rest_api_id = aws_api_gateway_rest_api.reservations.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      module.apigw_resources[*].resource_id,
      module.apigw_resources[*].method_id,
      module.apigw_resources[*].integration_id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_api_gateway_stage" "reservations" {
  deployment_id = aws_api_gateway_deployment.reservations.id
  rest_api_id   = aws_api_gateway_rest_api.reservations.id
  stage_name    = "test"
}

resource "aws_api_gateway_api_key" "reservations" {
  name = "${var.apigw_name}key"
}

resource "aws_api_gateway_usage_plan_key" "reservations" {
  key_id        = aws_api_gateway_api_key.reservations.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.reservations.id
}

resource "aws_api_gateway_usage_plan" "reservations" {
  name         = var.apigw_name
  description  = "test"
  product_code = var.apigw_name

  api_stages {
    api_id = aws_api_gateway_rest_api.reservations.id
    stage  = aws_api_gateway_stage.reservations.stage_name
  }

  quota_settings {
    limit  = 1000
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 100
  }
}

module "apigw_resources" {
  count               = length(var.apigw_resources)
  source              = "./apigw_resource"
  fn_name             = var.apigw_resources[count.index][0]
  http_method         = var.apigw_resources[count.index][1]
  lambda_role_arn     = var.lambda_role_arn
  lambda_build        = var.apigw_resources[count.index][2]
  apigw_id            = aws_api_gateway_rest_api.reservations.id
  root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
  apigw_execution_arn = local.apigw_execution_arn
}

# module "get_res_resource" {
#   source              = "./apigw_resource"
#   fn_name             = "get-res"
#   http_method         = "GET"
#   lambda_role_arn     = aws_iam_role.reservations_lambdas.arn
#   lambda_build        = "58"
#   apigw_id            = aws_api_gateway_rest_api.reservations.id
#   root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
#   apigw_execution_arn = local.apigw_execution_arn
# }

# module "add_res_resource" {
#   source              = "./apigw_resource"
#   fn_name             = "add-res"
#   http_method         = "POST"
#   lambda_role_arn     = aws_iam_role.reservations_lambdas.arn
#   lambda_build        = "59"
#   apigw_id            = aws_api_gateway_rest_api.reservations.id
#   root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
#   apigw_execution_arn = local.apigw_execution_arn
# }

# module "delete_res_resource" {
#   source              = "./apigw_resource"
#   fn_name             = "delete-res"
#   http_method         = "POST"
#   lambda_role_arn     = aws_iam_role.reservations_lambdas.arn
#   lambda_build        = "60"
#   apigw_id            = aws_api_gateway_rest_api.reservations.id
#   root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
#   apigw_execution_arn = local.apigw_execution_arn
# }