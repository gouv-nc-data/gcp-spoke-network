<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub-to-spoke-peering"></a> [hub-to-spoke-peering](#module\_hub-to-spoke-peering) | git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc-peering | v26.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc | v26.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.default-allow-internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | id du projet | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"europe-west1"` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | subnet dans lequel s'executent les data proc | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->