provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}


module "vpc_one" {

  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "vpc_one_public_network_1" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc_one.vpc_id
  cidr_block        = "10.0.0.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  igw_id            = module.vpc_one.igw_id
}

module "vpc_one_public_network_2" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc_one.vpc_id
  cidr_block        = "10.0.64.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  igw_id            = module.vpc_one.igw_id
}

module "vpc_one_private_network_1" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc_one.vpc_id
  cidr_block        = "10.0.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  nat_gateway_id    = module.vpc_one_public_network_1.nat_gateway_id
}

module "vpc_one_private_network_2" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc_one.vpc_id
  cidr_block        = "10.0.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  nat_gateway_id    = module.vpc_one_public_network_2.nat_gateway_id
  #whitelist = "0.0.0.0/0"
}

resource "aws_vpc_endpoint" "VPCE" {
  vpc_id            = module.vpc_one.vpc_id #Gained from VPC Module
  service_name      = "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc_one.vpce_security_group, #Gained from VPC Module
  ]

  subnet_ids = [module.vpc_one_private_network_1.subnet_id, module.vpc_one_private_network_2.subnet_id] # Gained from Private_network (see if there's a way to add all available)

  private_dns_enabled = true
}

module "iam" {   #Once connectivity is good by default we no longer need this
  source = "../../modules/iam"
}

module "vpc_one_instance" {   #Once connectivity is good by default we no longer need this
  source            = "../../modules/instance"
  availability_zone = data.aws_availability_zones.available.names[0]
  security_groups   = [module.vpc_one.instance_security_group]
  subnet_id         = module.vpc_one_private_network_1.subnet_id
  instance_profile  = module.iam.profile_name
}

module "rest_api" {
  source   = "../../modules/rest_api"
  vpc_id   = module.vpc_one.vpc_id          #Gained from VPC Module
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

module "inside_tgw"{
  source = "../../modules/tgw"
  region = "us-east-1"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  subnet_ids         = [module.vpc_one_private_network_1.subnet_id, module.vpc_one_private_network_2.subnet_id]
  transit_gateway_id = module.inside_tgw.tgw_id
  vpc_id             = module.vpc_one.vpc_id
}


##-----------------------------------------------------------------------------------------------
module "vpc_two" {

  source     = "../../modules/vpc"
  cidr_block = "10.100.0.0/16"
}

module "vpc_two_public_network_1" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc_two.vpc_id
  cidr_block        = "10.100.0.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  igw_id            = module.vpc_two.igw_id
}

module "vpc_two_public_network_2" {

  source            = "../../modules/public_network"
  vpc_id            = module.vpc_two.vpc_id
  cidr_block        = "10.100.64.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  igw_id            = module.vpc_two.igw_id
}

module "vpc_two_private_network_1" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc_two.vpc_id
  cidr_block        = "10.100.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  nat_gateway_id    = module.vpc_two_public_network_1.nat_gateway_id
}

module "vpc_two_private_network_2" {

  source            = "../../modules/private_network"
  vpc_id            = module.vpc_two.vpc_id
  cidr_block        = "10.100.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  nat_gateway_id    = module.vpc_two_public_network_2.nat_gateway_id
}

module "vpc_two_instance" {
  source            = "../../modules/instance"
  availability_zone = data.aws_availability_zones.available.names[0]
  security_groups   = [module.vpc_two.instance_security_group]
  subnet_id         = module.vpc_two_private_network_1.subnet_id
  instance_profile  = module.iam.profile_name
}