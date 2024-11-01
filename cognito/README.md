<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_cognito_user.adjudicator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user.analyst](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user_group.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_group.edit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_group.read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_in_group.adjudicator_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_in_group) | resource |
| [aws_cognito_user_in_group.admin_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_in_group) | resource |
| [aws_cognito_user_in_group.analyst_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_in_group) | resource |
| [aws_cognito_user_pool.userpool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_client.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_iam_policy.admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.admin_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_url"></a> [app\_url](#input\_app\_url) | URL of the application | `string` | `"http://localhost:3000/"` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base Name | `string` | n/a | yes |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | Callback URLs for Cognito | `list(string)` | <pre>[<br>  "http://localhost:3000/"<br>]</pre> | no |
| <a name="input_cognito_role"></a> [cognito\_role](#input\_cognito\_role) | Cognito Role | `string` | n/a | yes |
| <a name="input_cognito_signup_lambda_arn"></a> [cognito\_signup\_lambda\_arn](#input\_cognito\_signup\_lambda\_arn) | Lambda ARN for Cognito Signup | `string` | n/a | yes |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | Logout URLs for Cognito | `list(string)` | <pre>[<br>  "http://localhost:3000/"<br>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_client_id"></a> [app\_client\_id](#output\_app\_client\_id) | The ID of the app client |
| <a name="output_app_client_secret"></a> [app\_client\_secret](#output\_app\_client\_secret) | The secret of the app client |
| <a name="output_app_userpool_domain"></a> [app\_userpool\_domain](#output\_app\_userpool\_domain) | The domain of the app user pool |
| <a name="output_default_user_accounts"></a> [default\_user\_accounts](#output\_default\_user\_accounts) | Cognito default user accounts |
| <a name="output_userpool_id"></a> [userpool\_id](#output\_userpool\_id) | The ID of the user pool |
| <a name="output_web_client_id"></a> [web\_client\_id](#output\_web\_client\_id) | The ID of the web client |
| <a name="output_web_userpool_domain"></a> [web\_userpool\_domain](#output\_web\_userpool\_domain) | The domain of the web user pool |
<!-- END_TF_DOCS -->