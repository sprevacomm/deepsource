variable "base_name" {
  description = "Base Name"
  type        = string
}

variable "app_url" {
  default     = "http://localhost:3000/"
  description = "URL of the application"
  type        = string
}

variable "callback_urls" {
  default     = ["http://localhost:3000/"]
  description = "Callback URLs for Cognito"
  type        = list(string)
}

variable "logout_urls" {
  default     = ["http://localhost:3000/"]
  description = "Logout URLs for Cognito"
  type        = list(string)
}

variable "cognito_role" {
  description = "Cognito Role"
  type        = string
}

variable "cognito_signup_lambda_arn" {
  description = "Lambda ARN for Cognito Signup"
  type        = string
}
