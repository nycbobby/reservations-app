output "standby_lambda_role_arn" {
  value = aws_iam_role.standby_lambda.arn
}

output "reservations_lambda_role_arn" {
  value = aws_iam_role.reservations_lambdas.arn
}