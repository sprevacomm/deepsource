variable "allocated_storage" {
  default     = 300
  description = "The allocated storage in gigabytes"
  type        = number
}

variable "storage_type" {
  default     = "gp2"
  description = "The type of storage to be used"
  type        = string
}

variable "engine" {
  default     = "postgres"
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  default     = "15"
  description = "The engine version to use"
  type        = string
}

variable "instance_class" {
  default     = "db.t3.large"
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_name" {
  default     = "postgres"
  description = "The name of the database to create"
  type        = string
}

variable "identifier" {
  description = "The name of the database identifier"
  type        = string
}

variable "db_username" {
  default     = "postgres"
  description = "Username for the database"
  type        = string
}

variable "subnet_ids" {
  description = "RDS Subnet_ids"
  type        = list(any)
}

variable "db_parameter_group" {
  default     = "default.postgres15"
  description = "The name of the DB parameter group to associate"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the RDS instance and security group will be created"
  type        = string
}

variable "db_password" {
  description = "Password for the master user of the database"
  type        = string
  default     = ""
}
