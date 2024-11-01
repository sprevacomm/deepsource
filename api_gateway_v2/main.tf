resource "aws_apigatewayv2_api" "http" {
  name          = var.app_name
  protocol_type = "HTTP"
}
