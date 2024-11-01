variable "base_name" {
  description = "Base Name"
  type        = string
}
variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs"
  type        = list(string)
}

variable "subnet_cidrs" {
  description = "List of subnet CIDRs"
  type        = list(string)
}

variable "databricks_account_id" {
  description = "Databricks account id"
  type        = string
}
