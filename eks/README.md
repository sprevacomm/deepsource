# Terraform AWS EKS Configuration

This Terraform project creates an AWS EKS (Elastic Kubernetes Service) cluster and associated resources.

## Prerequisites

Before running the Terraform code, ensure you have the following prerequisites:

- AWS account and credentials configured.
- Terraform installed (version 0.13+ recommended).
- Required variables defined (see `variables.tf` for details).

## Terraform Resources

### `aws_eks_cluster`

This resource defines the AWS EKS cluster with the following settings:

- Cluster name: `trade-craft-eks-cluster`
- EKS version: `1.26`
- VPC configuration with specified subnet IDs.

### `aws_eks_addon`

We create three EKS add-ons:

1. `vpc_cni` (Amazon VPC CNI)
2. `coredns` (CoreDNS)
3. `kubeproxy` (kube-proxy)

Each add-on is associated with the EKS cluster created above.

### `aws_eks_node_group`

This resource defines an EKS node group with the following settings:

- Node group name: `trade-craft-node-group`
- Associated with the EKS cluster.
- Auto-scaling configuration for node instances.
- Instance type: `t3.2xlarge`
- Amazon Machine Image (AMI) type: `AL2_x86_64`
- Disk size: `300 GB`
- Tags the nodes with a `Name` tag.

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_eks_addon.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.aws_ebs_csi_driver_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudwatch_agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_cni_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts) | List of account maps to add to the aws-auth configmap | `list(string)` | `[]` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | List of role maps to add to the aws-auth configmap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of user maps to add to the aws-auth configmap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name | `string` | n/a | yes |
| <a name="input_ec2_ssh_key"></a> [ec2\_ssh\_key](#input\_ec2\_ssh\_key) | EC2 SSH key for remote access to managed node group | `string` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | EKS version | `string` | `"1.28"` | no |
| <a name="input_node_group_config"></a> [node\_group\_config](#input\_node\_group\_config) | Node group configuration | <pre>object({<br>    instance_types = list(string)<br>    desired_size   = number<br>    min_size       = number<br>    max_size       = number<br>    ami_type       = string<br>    disk_size      = number<br>  })</pre> | <pre>{<br>  "ami_type": "AL2_x86_64",<br>  "desired_size": 3,<br>  "disk_size": 300,<br>  "instance_types": [<br>    "t3.2xlarge"<br>  ],<br>  "max_size": 5,<br>  "min_size": 3<br>}</pre> | no |
| <a name="input_remote_access_security_groups"></a> [remote\_access\_security\_groups](#input\_remote\_access\_security\_groups) | List of security group IDs allowed remote access to the cluster | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs | `list(string)` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_auto_scaling_group_name"></a> [cluster\_auto\_scaling\_group\_name](#output\_cluster\_auto\_scaling\_group\_name) | Cluster Auto Scaling Group Name |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name |
| <a name="output_cluster_oidc_arn"></a> [cluster\_oidc\_arn](#output\_cluster\_oidc\_arn) | Cluster OIDC Provider ARN |
| <a name="output_cluster_oidc_audience"></a> [cluster\_oidc\_audience](#output\_cluster\_oidc\_audience) | Cluster OIDC Provider Audience |
| <a name="output_cluster_oidc_subject"></a> [cluster\_oidc\_subject](#output\_cluster\_oidc\_subject) | Cluster OIDC Provider Subject |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Cluster Secuirty Group ID |
<!-- END_TF_DOCS -->
