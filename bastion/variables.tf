variable "vpc_id" {
  description = "The VPC ID for the bastion server"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "base_name" {
  description = "Base name"
  type        = string
}

variable "instance_type" {
  default     = "t3.medium"
  description = "Bastion instance size"
  type        = string
}

variable "ec2_ssh_key" {
  description = "EC2 SSH key for remote access to the bastion server"
  type        = string
}

variable "ec2_instance_connect_sg" {
  description = "EC2 instance connect security group"
  type        = string
}

variable "helm_version" {
  default     = "3.13.2"
  description = "Helm tool version"
  type        = string
}

variable "terraform_version" {
  default     = "1.6.3"
  description = "Terraform tool version"
  type        = string
}

variable "kubectl_version" {
  default     = "1.28.3"
  description = "Kubectl tool version"
  type        = string
}
