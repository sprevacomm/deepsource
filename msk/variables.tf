variable "base_name" {
  description = "Base Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnets" {
  description = "A list of subnets"
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "List of subnet CIDRs"
  type        = list(string)
}
