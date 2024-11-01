output "repo_name" {
  description = "The name of the ECR repo"
  value       = aws_ecr_repository.repo.name
}

output "repo_arn" {
  description = "The ARN of the ECR repo"
  value       = aws_ecr_repository.repo.arn
}

output "repo_url" {
  description = "The URL of the ECR repo"
  value       = aws_ecr_repository.repo.repository_url
}
