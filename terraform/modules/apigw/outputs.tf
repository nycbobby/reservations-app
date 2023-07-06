output "apigw_invoke_url" {
  value = aws_api_gateway_stage.reservations.invoke_url
}

output "api_key" {
  value     = aws_api_gateway_api_key.reservations.value
  sensitive = true
}