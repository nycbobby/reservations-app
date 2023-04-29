output "integration_id" {
  value = aws_api_gateway_integration.function.id
}

output "method_id" {
    value = aws_api_gateway_method.function.id
}

output "resource_id" {
    value = aws_api_gateway_resource.function.id
}