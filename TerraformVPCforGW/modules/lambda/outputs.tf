output "uri" {
  value = aws_lambda_function.Lambda_MadeByTerraform.invoke_arn
}