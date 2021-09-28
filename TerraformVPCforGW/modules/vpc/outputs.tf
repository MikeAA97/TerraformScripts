output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpce_security_group" {
  value = aws_security_group.VPCE_SG.id
}

output "instance_security_group" {
  value = aws_security_group.Instance_SG.id
}

output "igw_id" {
  value = aws_internet_gateway.IGW.id
}