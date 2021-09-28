resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id #External Dependency
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route = [
    {
      cidr_block = var.whitelist
      gateway_id = var.igw_id #External Dependency

      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]
  #depends_on = [module.vpc.vpc_id] #External Dependency

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet.id

  tags = {
    Name = "Made by Terraform"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}