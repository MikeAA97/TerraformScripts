output "rest_api_id" {
  value = aws_api_gateway_rest_api.RestAPI.id
}

output "rest_api_method" {
  value = aws_api_gateway_method.RestAPIMethod.http_method
}

output "rest_api_path" {
  value = aws_api_gateway_resource.RestAPIResource.path
}
