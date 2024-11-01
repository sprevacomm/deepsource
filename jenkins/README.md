<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | 3.0.2 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_docker"></a> [docker](#provider\_docker) | 3.0.2 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_iam_role.jenkins_agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [docker_image.base](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [docker_image.cypress](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [docker_image.react](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [docker_image.ruby](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [docker_registry_image.base](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/registry_image) | resource |
| [docker_registry_image.cypress](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/registry_image) | resource |
| [docker_registry_image.react](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/registry_image) | resource |
| [docker_registry_image.ruby](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/registry_image) | resource |
| [helm_release.jenkins](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding.jenkins_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.agent_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.agent_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_agent_repo"></a> [base\_agent\_repo](#input\_base\_agent\_repo) | Repo for the jenkins base agent | `string` | n/a | yes |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base Name | `string` | n/a | yes |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Cluster Domain Name | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster Name | `string` | n/a | yes |
| <a name="input_cluster_oidc_arn"></a> [cluster\_oidc\_arn](#input\_cluster\_oidc\_arn) | Cluster OIDC Provider ARN | `string` | n/a | yes |
| <a name="input_cluster_oidc_audience"></a> [cluster\_oidc\_audience](#input\_cluster\_oidc\_audience) | Cluster OIDC Provider Audience | `string` | n/a | yes |
| <a name="input_cluster_oidc_subject"></a> [cluster\_oidc\_subject](#input\_cluster\_oidc\_subject) | Cluster OIDC Provider Subject | `string` | n/a | yes |
| <a name="input_cypress_agent_repo"></a> [cypress\_agent\_repo](#input\_cypress\_agent\_repo) | Repo for the jenkins cypress agent | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Jenkins Domain Name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Map of environment variables | `map(string)` | `{}` | no |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | Github Personal Access Token | `string` | n/a | yes |
| <a name="input_github_repo_names"></a> [github\_repo\_names](#input\_github\_repo\_names) | Github Repo Names | `list(string)` | `[]` | no |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | Github Repo Owner | `string` | n/a | yes |
| <a name="input_github_user"></a> [github\_user](#input\_github\_user) | Github Username | `string` | n/a | yes |
| <a name="input_kaniko_container_types"></a> [kaniko\_container\_types](#input\_kaniko\_container\_types) | Repo for the jenkins cypress agent | `list(string)` | <pre>[<br>  "be",<br>  "fe",<br>  "etl"<br>]</pre> | no |
| <a name="input_react_agent_repo"></a> [react\_agent\_repo](#input\_react\_agent\_repo) | Repo for the jenkins react agent | `string` | n/a | yes |
| <a name="input_ruby_agent_repo"></a> [ruby\_agent\_repo](#input\_ruby\_agent\_repo) | Repo for the jenkins ruby agent | `string` | n/a | yes |
| <a name="input_secret_env"></a> [secret\_env](#input\_secret\_env) | Map of secret environment variables | `map(string)` | `{}` | no |
| <a name="input_sonarqube_token"></a> [sonarqube\_token](#input\_sonarqube\_token) | Sonarqube Token | `string` | n/a | yes |
| <a name="input_sonarqube_url"></a> [sonarqube\_url](#input\_sonarqube\_url) | Sonarqube URL | `string` | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | Stages | `list(string)` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Admin password for Jenkins |
| <a name="output_base_image"></a> [base\_image](#output\_base\_image) | Jenkins agent image |
| <a name="output_base_image_repo_digest"></a> [base\_image\_repo\_digest](#output\_base\_image\_repo\_digest) | Jenkins agent image |
| <a name="output_base_registry_image"></a> [base\_registry\_image](#output\_base\_registry\_image) | Jenkins agent registry image |
<!-- END_TF_DOCS -->