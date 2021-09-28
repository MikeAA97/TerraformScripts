variable "vpce_ids" {
  type        = set(string)
  description = "Set of VPCE IDs used to configure API Endpoints"
}

variable "uri" {
  type        = string
  description = "uri"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC"
}

variable "vpce_id" {
    type = string
    description = "VPCE ID(s) used to configure API Policy"
}

