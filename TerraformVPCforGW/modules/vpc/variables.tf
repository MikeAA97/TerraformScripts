variable "cidr_block" {
  type        = string
  description = "The CIDR Block for this subnet, usually a section of the VPC CIDR"
  default     = "10.0.0.0/16"
}