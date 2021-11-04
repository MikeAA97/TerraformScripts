provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "Terraform-TGW"
}