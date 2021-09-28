data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline.zip"
  source {
    content  = <<EOF
exports.handler = async (event) => {const response = {statusCode: 200, body: JSON.stringify('Hello from Lambda!'),}; return response;};
EOF
    filename = "index.js"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}