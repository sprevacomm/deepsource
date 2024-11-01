output "http_api_gateway_endpoint_url" {
  description = "The URL of the HTTP API Gateway endpoint"
  value       = aws_apigatewayv2_api.http.api_endpoint
}
