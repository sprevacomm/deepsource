<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.66.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.66.0 |
| <a name="provider_aws.parent"></a> [aws.parent](#provider\_aws.parent) | 5.66.0 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | 5.66.0 |

### Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.global](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/resources/acm_certificate) | resource |
| [aws_route53_record.acm_validation](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/resources/route53_record) | resource |
| [aws_route53_record.root](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/resources/route53_record) | resource |
| [aws_route53_zone.self](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/resources/route53_zone) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/data-sources/region) | data source |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/5.66.0/docs/data-sources/route53_zone) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The primary domain (cluster domain) | `string` | n/a | yes |
| <a name="input_root_domain"></a> [root\_domain](#input\_root\_domain) | The root (base) domain | `string` | n/a | yes |
| <a name="input_wildcard_subdomains"></a> [wildcard\_subdomains](#input\_wildcard\_subdomains) | List of wildcard subdomains | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the ACM certificate |
| <a name="output_acm_certificate_domain"></a> [acm\_certificate\_domain](#output\_acm\_certificate\_domain) | The domain name of the ACM certificate |
| <a name="output_acm_certificate_sans"></a> [acm\_certificate\_sans](#output\_acm\_certificate\_sans) | The subject alternative names of the ACM certificate |
| <a name="output_global_acm_certificate_arn"></a> [global\_acm\_certificate\_arn](#output\_global\_acm\_certificate\_arn) | The ARN of the Global ACM certificate |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->