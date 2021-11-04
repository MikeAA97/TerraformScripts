variable "cidr_block" {
  type        = string
  description = "The CIDR Block for this subnet, usually a section of the VPC CIDR"
  default     = "172.16.0.0/16"
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