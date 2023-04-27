locals {
  apigw_execution_arn = "${aws_api_gateway_rest_api.reservations.execution_arn}/*"
}

resource "aws_api_gateway_rest_api" "reservations" {
  name = "reservations"
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
      module.get_res_resource.resource_id,
      module.get_res_resource.method_id,
      module.get_res_resource.integration_id,
      module.add_res_resource.resource_id,
      module.add_res_resource.method_id,
      module.add_res_resource.integration_id,
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
  name = "reservationskey"
}

resource "aws_api_gateway_usage_plan_key" "reservations" {
  key_id        = aws_api_gateway_api_key.reservations.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.reservations.id
}

resource "aws_api_gateway_usage_plan" "reservations" {
  name         = "reservations"
  description  = "test"
  product_code = "reservations"

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

module "get_res_resource" {
  source              = "./modules/apigw_resource"
  fn_name             = "get-res"
  http_method         = "GET"
  lambda_role_arn     = aws_iam_role.iam_for_lambda.arn
  lambda_build        = "21"
  apigw_id            = aws_api_gateway_rest_api.reservations.id
  root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
  apigw_execution_arn = local.apigw_execution_arn
}

module "add_res_resource" {
  source              = "./modules/apigw_resource"
  fn_name             = "add-res"
  http_method         = "PUT"
  lambda_role_arn     = aws_iam_role.iam_for_lambda.arn
  lambda_build        = "25"
  apigw_id            = aws_api_gateway_rest_api.reservations.id
  root_resource_id    = aws_api_gateway_rest_api.reservations.root_resource_id
  apigw_execution_arn = local.apigw_execution_arn
}