provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}


module "vpc" {

  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "public_network_1" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.0.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  igw_id            = module.vpc.igw_id
  #whitelist = "0.0.0.0/0"
}

module "public_network_2" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.64.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  igw_id            = module.vpc.igw_id
  #whitelist = "0.0.0.0/0"
}

module "private_network_1" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  nat_gateway_id    = module.public_network_1.nat_gateway_id
  #whitelist = "0.0.0.0/0"
}

module "private_network_2" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  nat_gateway_id    = module.public_network_2.nat_gateway_id
  #whitelist = "0.0.0.0/0"
}

resource "aws_vpc_endpoint" "VPCE" {
  vpc_id            = module.vpc.vpc_id #Gained from VPC Module
  service_name      = "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc.vpce_security_group, #Gained from VPC Module
  ]

  subnet_ids = [module.private_network_1.subnet_id, module.private_network_2.subnet_id] # Gained from Private_network (see if there's a way to add all available)

  private_dns_enabled = true
}

module "instance" {
  source            = "../../modules/instance"
  availability_zone = data.aws_availability_zones.available.names[0]
  security_groups   = [module.vpc.instance_security_group]
  subnet_id         = module.private_network_1.subnet_id
}

module "rest_api" {
  source   = "../../modules/rest_api"
  vpc_id   = module.vpc.vpc_id          #Gained from VPC Module
  vpce_ids = [aws_vpc_endpoint.VPCE.id] #Gained from VPC Module
  uri      = module.lambda.uri          #Gained from VPC Module
  vpce_id = aws_vpc_endpoint.VPCE.id
}

module "lambda" {
  source          = "../../modules/lambda"
  rest_api_id     = module.rest_api.rest_api_id     #Gained from VPC Module
  rest_api_method = module.rest_api.rest_api_method #Gained from VPC Module
  rest_api_path   = module.rest_api.rest_api_path   #Gained from VPC Module
}