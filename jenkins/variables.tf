variable "cluster_oidc_arn" {
  description = "Cluster OIDC Provider ARN"
  type        = string
}

variable "cluster_oidc_subject" {
  description = "Cluster OIDC Provider Subject"
  type        = string
}

variable "cluster_oidc_audience" {
  description = "Cluster OIDC Provider Audience"
  type        = string
}

variable "github_pat" {
  description = "Github Personal Access Token"
  type        = string
}

variable "github_user" {
  description = "Github Username"
  type        = string
}

variable "github_repo_owner" {
  description = "Github Repo Owner"
  type        = string
}

variable "github_repo_names" {
  default     = []
  description = "Github Repo Names"
  type        = list(string)
}

variable "sonarqube_url" {
  description = "Sonarqube URL"
  type        = string
}

variable "sonarqube_token" {
  description = "Sonarqube Token"
  type        = string
}

variable "base_name" {

  description = "Base Name"
  type        = string
}

variable "domain" {
  description = "Jenkins Domain Name"
  type        = string
}

variable "cluster_domain" {
  description = "Cluster Domain Name"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "stages" {
  description = "Stages"
  type        = list(string)
}

variable "env" {
  default     = {}
  description = "Map of environment variables"
  type        = map(string)
}

variable "secret_env" {
  default     = {}
  description = "Map of secret environment variables"
  type        = map(string)
}

variable "base_agent_repo" {
  description = "Repo for the jenkins base agent"
  type        = string
}

variable "ruby_agent_repo" {
  description = "Repo for the jenkins ruby agent"
  type        = string
}

variable "react_agent_repo" {
  description = "Repo for the jenkins react agent"
  type        = string
}

variable "cypress_agent_repo" {
  description = "Repo for the jenkins cypress agent"
  type        = string
}

variable "kaniko_container_types" {
  description = "Repo for the jenkins cypress agent"
  type        = list(string)
  default     = ["be", "fe", "etl"]
}
