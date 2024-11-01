# Terraform Helm Release for Ingress Nginx

## Overview

This Terraform configuration deploys the Ingress Nginx Helm chart to your Kubernetes cluster. Ingress Nginx is a popular open-source reverse proxy and load balancer that simplifies handling external traffic to services within a Kubernetes cluster.

### Prerequisites

Before using this Terraform code, ensure you have the following prerequisites in place:

- A functioning Kubernetes cluster.
- Helm installed and properly configured on your local machine or within your Kubernetes cluster.
- Terraform installed (recommended version: 0.13+).

### Terraform Resource

#### `helm_release`

This Terraform resource manages the deployment of the Ingress Nginx Helm chart with the following configuration:

- `name`: The name assigned to the Helm release, set to "ingress-nginx."
- `repository`: The Helm chart repository where the Ingress Nginx chart is hosted.
- `chart`: The name of the Helm chart to install, which is "ingress-nginx."
- `version`: The specific version of the Helm chart to deploy (for example, "4.8").

In addition to deploying the Helm chart, this resource is also configured with several important settings:

- `namespace`: The Kubernetes namespace in which to install the chart, set to "ingress-nginx."
- `create_namespace`: If set to true, Terraform will create the specified namespace if it doesn't already exist.
- `set`: This section allows you to customize specific Helm chart values. For instance, it configures the service type to "LoadBalancer" and enables the default ingress class resource.

<!-- BEGIN_TF_DOCS -->


### Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

### Resources

| Name | Type |
|------|------|
| [helm_release.ingress-nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
<!-- END_TF_DOCS -->
