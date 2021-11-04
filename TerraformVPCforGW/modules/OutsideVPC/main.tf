resource "aws_vpc" "outside" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "OutsideVPC"
  }
}
//----------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.outside.id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.outside.id

  route = [
    {
      cidr_block = var.whitelist
      gateway_id = ""

      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = aws_nat_gateway.nat_gateway.id
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public.id
  connectivity_type = "private"

  tags = {
    Name = "Made by Terraform"
  }
}
//-------------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.outside.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.outside.id

  route = [
    {
      cidr_block     = var.whitelist
      nat_gateway_id = aws_nat_gateway.nat_gateway.id

      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      gateway_id                 = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "Instance_SG" {

  name        = "Instance_SG"
  description = "SG for Instance"
  vpc_id      = aws_vpc.outside.id

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_security_group_rule" "Instance_Egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.Instance_SG.id
}

resource "aws_security_group_rule" "Instance_Ingress" {
  type              = "ingress"
  from_port         = "8"
  to_port           = "0"
  protocol          = "ICMP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.Instance_SG.id
}