variable "root_domain" {
  description = "The root (base) domain"
  type        = string
}

variable "domain" {
  description = "The primary domain (cluster domain)"
  type        = string
}

variable "wildcard_subdomains" {
  default     = []
  description = "List of wildcard subdomains"
  type        = list(string)
}
