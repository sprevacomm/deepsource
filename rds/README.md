<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_db_instance.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.my_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_kms_alias.rds_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.rds_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gigabytes | `number` | `300` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database to create | `string` | `"postgres"` | no |
| <a name="input_db_parameter_group"></a> [db\_parameter\_group](#input\_db\_parameter\_group) | The name of the DB parameter group to associate | `string` | `"default.postgres15"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Password for the master user of the database | `string` | `""` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Username for the database | `string` | `"postgres"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version to use | `string` | `"15"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The name of the database identifier | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS instance | `string` | `"db.t3.large"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The type of storage to be used | `string` | `"gp2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | RDS Subnet\_ids | `list(any)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID where the RDS instance and security group will be created | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The address of the RDS instance |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The username for the RDS instance |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The connection endpoint |
| <a name="output_password"></a> [password](#output\_password) | The password for the master DB user |
| <a name="output_port"></a> [port](#output\_port) | The port on which the RDS instance is accessible |
| <a name="output_username"></a> [username](#output\_username) | The username for the RDS instance |
<!-- END_TF_DOCS -->