data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-function"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "sign_up_users" {
  function_name = var.function_name
  role          = var.lambda_exec_role
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  filename      = data.archive_file.lambda_zip.output_path

  lifecycle {
    ignore_changes = [
      filename, source_code_hash
    ]
  }

  depends_on = [data.archive_file.lambda_zip]
}
