variable "base_name" {
  description = "Base Name"
  type        = string
}

variable "repo_name" {
  description = "Name of the repo"
  type        = string
}

variable "scan_on_push" {
  default     = true
  description = "Scan on push"
  type        = bool
}
