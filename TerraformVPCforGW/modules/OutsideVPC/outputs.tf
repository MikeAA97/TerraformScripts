output "instance_security_group" {
  value = aws_security_group.Instance_SG.id
}

output "subnet_id" {
  value = aws_subnet.private.id
}

output "vpc_id" {
  value = aws_vpc.outside.id
}