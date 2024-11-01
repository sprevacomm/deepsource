variable "base_name" {
  description = "Base Name"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Cluster Security Group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_asg_name" {
  description = "Name of the target ASG"
  type        = string
}

variable "project" {
  description = "Project Name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "domain" {
  description = "Domain Name"
  type        = string
}

variable "wildcard_subdomains" {
  description = "Wildcard subdomains"
  type        = list(string)
}
