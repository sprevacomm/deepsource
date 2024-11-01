variable "name_prefix" {
  type        = string
  description = "Prefix to be used for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EC2 instance"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to SSH to the instance"
  default     = []
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 50
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for HTTPS"
}


variable "route53_zone_id" {
  type        = string
  description = "ID of the Route 53 hosted zone"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the Route 53 zone (e.g., example.com)"
}

variable "ec2_instance_connect_sg" {
  description = "EC2 instance connect security group"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}
