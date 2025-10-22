# Setup Guide

This guide will walk you through setting up this template for your Azure integration project.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Azure subscription with Owner or Contributor access
- [ ] Azure CLI installed (`az --version` to verify)
- [ ] Git installed
- [ ] VS Code (recommended) with Bicep extension
- [ ] GitHub account and repository

## Step-by-Step Setup

### 1. Clone and Initialize Repository

```bash
# Clone this template
git clone https://github.com/your-org/orch.git my-project
cd my-project

# Remove existing git history and start fresh
rm -rf .git
git init
git add .
git commit -m "Initial commit from Orch template"

# Add your remote repository
git remote add origin https://github.com/your-org/my-project.git
git push -u origin main
```

### 2. Configure Project Settings

Edit `config/settings.json`:

```json
{
  "project": {
    "customerName": "YOUR_CUSTOMER_NAME",
    "projectName": "YOUR_PROJECT_NAME"
  },
  "azure": {
    "subscriptionId": "YOUR_SUBSCRIPTION_ID",
    "location": "swedencentral"
  },
  "naming": {
    "prefix": "YOUR_PREFIX"  // Keep it short (3-6 chars)
  }
}
```

**Important**: The `prefix` should be unique and short (3-6 characters) to avoid naming conflicts.

### 3. Update Parameter Files

For each environment file in `bicep/common/`, update:

- `prefix` - Match the prefix from settings.json
- `tags.Customer` - Your customer/organization name
- `tags.CostCenter` - Your cost center code
- `logAnalyticsWorkspaceId` - (Optional) Your Log Analytics workspace ID

Example for `parameters.dev.json`:

```json
{
  "parameters": {
    "prefix": {
      "value": "acme"  // Your prefix
    },
    "tags": {
      "value": {
        "Environment": "Development",
        "Customer": "Acme Corp",
        "Project": "D365 Integrations",
        "CostCenter": "IT-D365"
      }
    }
  }
}
```

### 4. Create Azure Service Principal

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Create service principal
az ad sp create-for-rbac \
  --name "sp-github-actions-YOUR_PROJECT" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth

# Copy the entire JSON output - you'll need it for GitHub
```

The output will look like:

```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  "activeDirectoryEndpointUrl": "...",
  "resourceManagerEndpointUrl": "...",
  "activeDirectoryGraphResourceId": "...",
  "sqlManagementEndpointUrl": "...",
  "galleryEndpointUrl": "...",
  "managementEndpointUrl": "..."
}
```

**Important**: Save this JSON securely - you cannot retrieve the clientSecret later!

### 5. Configure GitHub Environments and Secrets

#### Create Environments

1. Go to your GitHub repository
2. Navigate to **Settings** → **Environments**
3. Create four environments:
   - `dev`
   - `test`
   - `uat`
   - `prod`

#### Add Secrets to Each Environment

For **each** environment:

1. Click on the environment name
2. Click **Add Secret**
3. Name: `AZURE_CREDENTIALS`
4. Value: Paste the entire JSON output from step 4
5. Click **Add secret**

#### (Optional) Add Environment Protection Rules

For `prod` environment:

1. Enable **Required reviewers**
2. Add reviewers who must approve production deployments
3. Enable **Wait timer** if you want a delay before deployment

### 6. Register Azure Resource Providers

```bash
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.ManagedIdentity
az provider register --namespace Microsoft.Insights

# Check registration status
az provider show --namespace Microsoft.Web --query "registrationState"
```

### 7. Validate Templates Locally (Optional)

```bash
# Make the validation script executable
chmod +x scripts/validate-bicep.sh

# Run validation
./scripts/validate-bicep.sh
```

This will:
- Validate all Bicep templates
- Optionally run what-if analysis

### 8. Deploy Common Infrastructure

#### Option A: Using GitHub Actions (Recommended)

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **Deploy Common Infrastructure** workflow
4. Click **Run workflow**
5. Select:
   - **Branch**: `main`
   - **Environment**: `dev`
   - **What-If**: ✓ (checked for first run)
6. Click **Run workflow**

Review the what-if output, then run again without what-if to deploy.

#### Option B: Using Azure CLI

```bash
# Preview changes
az deployment sub what-if \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json

# Deploy
az deployment sub create \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json \
  --name common-infra-dev-001
```

### 9. Verify Deployment

After deployment, verify in Azure Portal:

1. **Resource Group**: `{prefix}-dev-common-rg`
2. **Key Vault**: `{prefix}devsdckv`
3. **Storage Account**: `{prefix}devsdcst`
4. **App Service Plan**: `{prefix}-dev-sdc-plan`
5. **Managed Identity**: `{prefix}devsdcid`

Check that:
- Managed Identity has RBAC roles on Key Vault and Storage
- Key Vault has soft delete and purge protection enabled
- Storage Account has the expected containers

### 10. Post-Deployment Configuration

#### Add Secrets to Key Vault

```bash
# Get Key Vault name
KV_NAME=$(az keyvault list --resource-group {prefix}-dev-common-rg --query "[0].name" -o tsv)

# Add a test secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "test-secret" \
  --value "test-value"
```

#### (Optional) Configure Log Analytics

If you want diagnostic logging:

```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group {prefix}-dev-common-rg \
  --workspace-name {prefix}-dev-sdc-law

# Get workspace ID
LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group {prefix}-dev-common-rg \
  --workspace-name {prefix}-dev-sdc-law \
  --query "id" -o tsv)

# Update parameter files with the workspace ID
```

Then redeploy with `enableDiagnostics: true` and the workspace ID.

## Next Steps

- [ ] Deploy to test, uat, prod environments
- [ ] Create your first integration (see Phase 2 documentation)
- [ ] Set up monitoring and alerts
- [ ] Configure CI/CD for your integration code
- [ ] Review security settings and adjust as needed

## Troubleshooting

### Common Issues

**Issue**: "Key Vault name already exists"

**Solution**: Key Vault names are globally unique. Change your `prefix` in parameter files or purge soft-deleted vault:

```bash
az keyvault purge --name {vault-name}
```

**Issue**: "Resource provider not registered"

**Solution**: Register required providers (see Step 6).

**Issue**: "Insufficient permissions"

**Solution**: Ensure your service principal has Contributor role on the subscription.

### Getting Help

- Review [README.md](../README.md) for detailed documentation
- Check [Azure Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- Review deployment logs in GitHub Actions or Azure Portal

## Cleanup

To remove all deployed resources:

```bash
# Delete resource group (this will delete all resources in it)
az group delete --name {prefix}-dev-common-rg --yes --no-wait

# Purge soft-deleted Key Vault
az keyvault purge --name {prefix}devsdckv
```

**Warning**: This is irreversible!
