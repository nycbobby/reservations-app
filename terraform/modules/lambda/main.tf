resource "aws_lambda_function" "function" {
  s3_bucket     = var.artifacts_bucket
  s3_key        = "${var.fn_name}-lambda-build-${var.lambda_build}"
  function_name = var.fn_name
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  role          = var.lambda_role_arn

  environment {
    variables = var.environment_vars
  }
}

module "lambda_schedule" {
  for_each            = var.schedule
  source              = "./event_rule"
  rule_name           = "${var.fn_name}-${each.key}"
  rule_desc           = "Daily at ${each.key}"
  lambda_arn          = aws_lambda_function.function.arn
  schedule_expression = each.value
}