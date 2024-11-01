<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_api_gateway_endpoint_url"></a> [http\_api\_gateway\_endpoint\_url](#output\_http\_api\_gateway\_endpoint\_url) | The URL of the HTTP API Gateway endpoint |
<!-- END_TF_DOCS -->