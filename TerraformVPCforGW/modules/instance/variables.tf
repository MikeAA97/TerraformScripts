variable "ami" {
  type        = string
  description = "The ami for the EC2 Instance"
  default     = "ami-087c17d1fe0178315"
}

variable "instance_type" {
  type        = string
  description = "Size for EC2 Instance"
  default     = "t3.nano"
}

variable "availability_zone" {
  type        = string
  description = "Availability where the EC2 Instance will be located"
  default     = "us-east-1a"
}

variable "security_groups" {
  type        = list(string)
  description = "Security Group that will be attached to the EC2 Instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet where the EC2 Instance will be located"
}


