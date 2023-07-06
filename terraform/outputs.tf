output "apigw_invoke_url" {
  value = module.apigw.apigw_invoke_url
}

output "api_key" {
  value     = module.apigw.api_key
  sensitive = true
}