output "glue_service_role" {
  description = "The ARN of the Glue IAM Service role"
  value       = aws_iam_role.glue_service_role.arn
}
