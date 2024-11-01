variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_engine" {
  description = "Database engine"
  default     = "aurora-postgresql"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  default     = "15.4"
  type        = string
}

variable "db_instance_count" {
  description = "Database instance count"
  default     = 1
  type        = number
}

variable "db_instance_class" {
  description = "Database instance class"
  default     = "db.t4g.medium"
  type        = string
}

variable "application_security_group_id" {
  description = "Application security group ID"
  type        = string
}
