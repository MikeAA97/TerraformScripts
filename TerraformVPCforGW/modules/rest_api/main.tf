resource "aws_api_gateway_rest_api" "RestAPI" {
  name = "RestAPI"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = var.vpce_ids #External Dependency
  }

}

resource "aws_api_gateway_resource" "RestAPIResource" {
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part   = "RestAPIResource"
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
}

resource "aws_api_gateway_method" "RestAPIMethod" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.RestAPIResource.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
}

resource "aws_api_gateway_integration" "RestAPIIntegration" {
  http_method             = aws_api_gateway_method.RestAPIMethod.http_method
  resource_id             = aws_api_gateway_resource.RestAPIResource.id
  rest_api_id             = aws_api_gateway_rest_api.RestAPI.id
  type                    = "AWS_PROXY"
  uri                     = var.uri #External Dependency
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "RestAPIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.RestAPIResource.id,
      aws_api_gateway_method.RestAPIMethod.id,
      aws_api_gateway_integration.RestAPIIntegration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "RestAPIStage" {
  deployment_id = aws_api_gateway_deployment.RestAPIDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  stage_name    = "test"
}

resource "aws_api_gateway_rest_api_policy" "RestAPIPolicy" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  #External Dependency Below
  
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpce": "${var.vpce_id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*"
        }
    ]
}
EOF
} 




#Depends on VPCE Creation