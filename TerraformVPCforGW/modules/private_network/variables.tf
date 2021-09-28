variable "cidr_block" {
  type        = string
  description = "The CIDR Block for this subnet, usually a section of the VPC CIDR"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone for this subnet"
}

variable "whitelist" {
  type        = string
  description = "Allow all IPv4 Addresses"
  default     = "0.0.0.0/0"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC"
}

variable "nat_gateway_id" {
  type        = string
  description = "ID of IGW"
}
