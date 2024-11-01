resource "aws_ecr_repository" "repo" {
  name         = "${var.base_name}/${var.repo_name}"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
