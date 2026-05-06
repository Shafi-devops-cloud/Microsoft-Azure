# Azure Function App (.NET Framework) Deployment with GitHub Actions

This guide explains how to deploy the **same package** to **UAT** and **PROD** using a **Service Principal** in GitHub Actions.

It is written for beginners and GitHub Enterprise users.

## Goal

- Build the Function App **once**
- Create one zip package artifact
- Deploy that exact same artifact to:
  - UAT
  - PROD
- Use separate environment settings and approvals

---

## Prerequisites

- Azure Function App exists for UAT and PROD
- You have Azure CLI access
- GitHub repository with Actions enabled
- (GHE) Required marketplace actions are allowlisted by your admin

Recommended allowlist:

- `actions/checkout`
- `NuGet/setup-nuget`
- `microsoft/setup-msbuild`
- `actions/upload-artifact`
- `actions/download-artifact`
- `azure/login`

---

## 1) Create Service Principal(s)

You can use:

- one SP with access to both UAT and PROD, or
- separate SPs (recommended for stricter security)

Example command (scope to one Function App):

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"

az ad sp create-for-rbac \
  --name "gh-func-deploy-sp-uat" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.Web/sites/<FUNCTION_APP_NAME> \
  --sdk-auth
```

Copy the full JSON output.

Repeat for PROD if you use separate principals.

---

## 2) Configure GitHub Environments

Create two environments in your repo:

- `uat`
- `prod`

In each environment, add:

### Secrets

- `AZURE_CREDENTIALS` = Service Principal JSON for that environment

### Variables

- `RESOURCE_GROUP` = resource group for that environment
- `FUNCTIONAPP_NAME` = function app name for that environment

### Protection (recommended)

For `prod`, enable:

- Required reviewers (manual approval)

---

## 3) Add Workflow File

Create `.github/workflows/deploy-uat-prod.yml`:

```yaml
name: Build once, deploy to UAT and PROD

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

env:
  PROJECT_PATH: ./YourFunctionApp.csproj
  BUILD_CONFIGURATION: Release
  ARTIFACT_NAME: functionapp-package

jobs:
  build:
    runs-on: windows-latest
    outputs:
      package-name: ${{ env.ARTIFACT_NAME }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup NuGet
        uses: NuGet/setup-nuget@v2

      - name: Setup MSBuild
        uses: microsoft/setup-msbuild@v2

      - name: Restore packages
        run: nuget restore ${{ env.PROJECT_PATH }}

      - name: Build
        run: msbuild ${{ env.PROJECT_PATH }} /p:Configuration=${{ env.BUILD_CONFIGURATION }}

      - name: Publish to folder
        run: msbuild ${{ env.PROJECT_PATH }} /p:Configuration=${{ env.BUILD_CONFIGURATION }} /p:DeployOnBuild=true /p:WebPublishMethod=FileSystem /p:PublishUrl=${{ github.workspace }}\published

      - name: Create zip package
        shell: pwsh
        run: Compress-Archive -Path "${{ github.workspace }}\published\*" -DestinationPath "${{ github.workspace }}\functionapp.zip" -Force

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.ARTIFACT_NAME }}
          path: ${{ github.workspace }}\functionapp.zip

  deploy-uat:
    runs-on: windows-latest
    needs: build
    environment: uat

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ needs.build.outputs.package-name }}
          path: ${{ github.workspace }}

      - name: Azure login (UAT SP)
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy to UAT Function App
        shell: pwsh
        run: |
          az functionapp deployment source config-zip `
            --resource-group "${{ vars.RESOURCE_GROUP }}" `
            --name "${{ vars.FUNCTIONAPP_NAME }}" `
            --src "${{ github.workspace }}\functionapp.zip"

  deploy-prod:
    runs-on: windows-latest
    needs: deploy-uat
    environment: prod

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ needs.build.outputs.package-name }}
          path: ${{ github.workspace }}

      - name: Azure login (PROD SP)
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy to PROD Function App
        shell: pwsh
        run: |
          az functionapp deployment source config-zip `
            --resource-group "${{ vars.RESOURCE_GROUP }}" `
            --name "${{ vars.FUNCTIONAPP_NAME }}" `
            --src "${{ github.workspace }}\functionapp.zip"
```

---

## 4) What to Customize

Update these values in workflow:

- `PROJECT_PATH` (path to your `.csproj`)
- trigger branch (`main` or your default branch)

Set environment values in GitHub:

- `uat` -> UAT app name/resource group/SP
- `prod` -> PROD app name/resource group/SP

---

## 5) Why This Design

- **Build once** ensures UAT and PROD receive identical bits
- Environment-scoped secrets/vars keep deployments clean and safer
- PROD approval gate reduces accidental production deployments

---

## 6) Troubleshooting

- Build fails on restore:
  - verify `PROJECT_PATH`
  - ensure private feeds are accessible (if used)
- Login fails:
  - verify `AZURE_CREDENTIALS` JSON is valid and not truncated
- Deploy fails with authorization:
  - ensure SP has correct scope/role on target Function App
- GHE action blocked:
  - ask admin to allow required actions listed above

---

## Optional Enhancements

- Deploy to PROD only on tags (for controlled releases)
- Add post-deploy smoke test after UAT before PROD
- Use separate Azure subscriptions per environment

