# Storage Account Private Endpoint using Terraform

This is a simple Terraform project that creates an Azure Storage Account with a private endpoint inside a virtual network.

## What Gets Created

- Resource group
- Virtual network
- Subnet
- Storage account
- Private endpoint for Blob Storage
- Private DNS zone for Blob Storage
- DNS link between the private DNS zone and VNet

## Terraform Files

- `versions.tf` - Terraform provider setup
- `variables.tf` - Azure location variable
- `main.tf` - Azure resources
- `outputs.tf` - useful output values
- `azure-pipelines.yml` - simple Azure DevOps pipeline

## Run Locally

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Change Azure Region

Edit `terraform.tfvars.example` or create a `terraform.tfvars` file:

```hcl
location = "eastus"
```

## Azure Pipeline

Before running the pipeline, update this value in `azure-pipelines.yml`:

```yaml
azureServiceConnection: "MY-SERVICE-CONNECTION"
```

The pipeline runs:

- Terraform init
- Terraform format check
- Terraform validate
- Terraform plan

The apply step is commented out. Uncomment it when you are ready to deploy resources.

## Important

The storage account disables public network access:

```hcl
public_network_access_enabled = false
```

So the storage account should be accessed through the private endpoint from inside the VNet.
