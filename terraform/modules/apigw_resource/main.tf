resource "aws_api_gateway_resource" "function" {
  parent_id   = var.root_resource_id
  path_part   = var.fn_name
  rest_api_id = var.apigw_id
}

resource "aws_api_gateway_method" "function" {
  authorization = "NONE"
  http_method   = var.http_method
  resource_id   = aws_api_gateway_resource.function.id
  rest_api_id   = var.apigw_id
}

resource "aws_api_gateway_integration" "function" {
  rest_api_id             = var.apigw_id
  resource_id             = aws_api_gateway_resource.function.id
  http_method             = aws_api_gateway_method.function.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = var.apigw_execution_arn
}

resource "aws_lambda_function" "function" {
  s3_bucket     = var.artifacts_bucket
  s3_key        = "${var.fn_name}-lambda-build-${var.lambda_build}"
  function_name = var.fn_name
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 180
  role          = var.lambda_role_arn
}