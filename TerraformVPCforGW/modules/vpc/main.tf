resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_security_group" "VPCE_SG" {

  name        = "TerraformManualVPCE"
  description = "SG for VPCE"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_security_group" "Instance_SG" {

  name        = "Instance_SG"
  description = "SG for Instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Made by Terraform"
  }
}

resource "aws_security_group_rule" "VPCE_Ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.VPCE_SG.id
}

resource "aws_security_group_rule" "VPCE_Egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.VPCE_SG.id
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

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Made by Terraform"
  }
}

