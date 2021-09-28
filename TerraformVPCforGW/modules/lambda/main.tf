resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Lambda_MadeByTerraform.function_name
  principal     = "apigateway.amazonaws.com"
  #External Dependecies below (Relies on rest_api module)
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/*/${var.rest_api_method}${var.rest_api_path}"
}

resource "aws_lambda_function" "Lambda_MadeByTerraform" {
  filename         = data.archive_file.lambda_zip_inline.output_path
  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256
  function_name    = "Lamda_MadeByTerraform"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"

  runtime = "nodejs12.x"

  depends_on = [aws_iam_role.lambda_role]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "Terraform-Sep26"
  }
}

#Variables to consider: iam role name, aws_lambda_function's name, handler, and runtime, aws_lambda_permissions's statement_id