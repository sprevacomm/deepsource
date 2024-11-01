<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_sonarqube"></a> [sonarqube](#requirement\_sonarqube) | 0.16.13 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_sonarqube"></a> [sonarqube](#provider\_sonarqube) | 0.16.13 |

### Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.sonarqube_jenkins_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.sonarqube_jenkins_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [sonarqube_user_token.jenkins](https://registry.terraform.io/providers/jdamata/sonarqube/0.16.13/docs/resources/user_token) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password | `string` | n/a | yes |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base Name | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_jenkins_token"></a> [jenkins\_token](#output\_jenkins\_token) | n/a |
| <a name="output_jenkins_token_arn"></a> [jenkins\_token\_arn](#output\_jenkins\_token\_arn) | n/a |
<!-- END_TF_DOCS -->