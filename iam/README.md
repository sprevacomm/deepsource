# Terraform AWS IAM Roles and Policies for Amazon EKS

This Terraform configuration sets up AWS IAM roles and attaches policies required for Amazon Elastic Kubernetes Service (EKS). These IAM roles are essential for EKS to function properly and allow cluster nodes to interact with the EKS control plane.

## Prerequisites

Before using this Terraform code, make sure you have the following prerequisites in place:

- An AWS account and credentials configured.
- Terraform installed (version 0.13+ recommended).

## Terraform Resources

### `aws_iam_role` - EKS Control Plane Role

This resource defines an IAM role for the EKS control plane:

- `name`: The name of the role, set to "eks-node-group-trade-craft."
- `assume_role_policy`: The IAM policy that defines who can assume this role, allowing EKS to manage the nodes.

### `aws_iam_role_policy_attachment` - EKS Control Plane Policy Attachment

This resource attaches the "AmazonEKSClusterPolicy" to the EKS control plane role.

### `aws_iam_role` - EKS Node Role

This resource defines an IAM role for the EKS worker nodes:

- `name`: The name of the role, set to "eks-node-role-trade-craft."
- `assume_role_policy`: The IAM policy that defines who can assume this role, allowing EC2 instances to join the EKS cluster.

### `aws_iam_role_policy_attachment` - EKS Node Policies Attachment

These resources attach necessary policies to the EKS node role:

1. "AmazonEKSWorkerNodePolicy": Provides permissions for worker nodes to register with the EKS cluster.
2. "AmazonEKS_CNI_Policy": Provides permissions for Amazon EKS to manage the VPC CNI.
3. "AmazonEC2ContainerRegistryReadOnly": Provides read-only access to Amazon ECR.
4. "AmazonEBSCSIDriverPolicy": Provides permissions for the Amazon EBS CSI (Container Storage Interface) driver.

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_role.cognito_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_user.smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base name | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognito_role"></a> [cognito\_role](#output\_cognito\_role) | The ARN of the Cognito IAM role |
| <a name="output_eks_access_role"></a> [eks\_access\_role](#output\_eks\_access\_role) | The ARN of the EKS IAM role |
| <a name="output_lambda_exec_role"></a> [lambda\_exec\_role](#output\_lambda\_exec\_role) | The ARN of the Lambda IAM role |
| <a name="output_smtp_password"></a> [smtp\_password](#output\_smtp\_password) | The SMTP password |
| <a name="output_smtp_username"></a> [smtp\_username](#output\_smtp\_username) | The SMTP username |
<!-- END_TF_DOCS -->
