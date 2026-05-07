# Azure Storage Account Private Endpoint with Terraform and Azure DevOps pipeline

This Terraform configuration creates:

- Resource group
- Virtual network and subnet for private endpoints
- Storage account with public network access disabled
- Private endpoint for the selected storage subresource
- Private DNS zone and VNet link

## Usage

```powershell
terraform init
terraform plan
terraform apply
```

To customize values:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Then edit `terraform.tfvars`.

## Azure Pipelines

The repository includes `azure-pipelines.yml` to run:

- `terraform init`
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`
- optional `terraform apply`

Before running the pipeline, update this variable in `azure-pipelines.yml`:

```yaml
azureServiceConnection: "MY-SERVICE-CONNECTION"
```

Use the name of an Azure DevOps service connection that has permission to create resources in the target subscription.

The apply step is commented out by default. When you are ready to create the Azure resources, uncomment the `Terraform Apply` step in `azure-pipelines.yml`.

## Storage Subresources

The default private endpoint is for Blob Storage:

```hcl
private_endpoint_subresource = "blob"
```

Supported values:

- `blob`
- `file`
- `queue`
- `table`
- `web`
- `dfs`

Each subresource uses the matching Azure private DNS zone, such as `privatelink.blob.core.windows.net` for Blob Storage.

## Notes

The storage account sets `public_network_access_enabled = false`, so access should resolve through the private endpoint from inside the linked VNet.
