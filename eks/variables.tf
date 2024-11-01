variable "eks_version" {
  type        = string
  default     = "1.28"
  description = "EKS version"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "node_group_config" {
  description = "Node group configuration"

  type = object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    ami_type       = string
    disk_size      = number
  })

  default = {
    instance_types = ["t3.2xlarge"]
    desired_size   = 3
    max_size       = 5
    min_size       = 3
    ami_type       = "AL2_x86_64"
    disk_size      = 300
  }
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_accounts" {
  default     = []
  description = "List of account maps to add to the aws-auth configmap"
  type        = list(string)
}

variable "ec2_ssh_key" {
  description = "EC2 SSH key for remote access to managed node group"
  type        = string
}

variable "remote_access_security_groups" {
  default     = []
  description = "List of security group IDs allowed remote access to the cluster"
  type        = list(string)
}
