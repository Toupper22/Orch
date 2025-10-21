# Configuration Management

## Overview

This project uses a **hierarchical configuration system** where global settings are defined once in `config/settings.json` and automatically propagated to all parameter files through generation scripts.

## Settings Hierarchy

```
config/settings.json (Global Settings - Source of Truth)
         ↓
   [Generation Scripts]
         ↓
bicep/common/parameters.{env}.json (Environment-specific)
bicep/integrations/*/parameters.{env}.json (Integration-specific)
         ↓
   [Deployment to Azure]
```

## Key Principle

**Settings that are the same across all environments are defined once in `config/settings.json`.**

Only environment-specific overrides (like SKUs, address spaces, retention periods) are in parameter files.

## Global Settings (config/settings.json)

### Project Settings
```json
{
  "project": {
    "customerName": "Contoso",           // Used in tags across all resources
    "projectName": "D365 Integrations",  // Used in tags across all resources
    "description": "..."
  }
}
```

### Azure Settings
```json
{
  "azure": {
    "location": "westeurope",      // Primary region for all deployments
    "locationShort": "weu"         // Used in resource naming
  }
}
```

### Naming Settings
```json
{
  "naming": {
    "prefix": "contoso",           // Prefix for all resource names
    "separator": "-"
  }
}
```

### Infrastructure Defaults
All common infrastructure settings like:
- Key Vault configuration
- Storage Account defaults
- App Service Plan settings
- Network configuration
- Managed Identity settings

## Environment-Specific Overrides

Environment-specific parameter files **only** contain values that differ per environment:

| Setting | dev | test | uat | prod |
|---------|-----|------|-----|------|
| App Service Plan SKU | Y1 | Y1 | EP1 | EP1 |
| VNet Address Space | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 | 10.3.0.0/16 |
| Key Vault Retention | 7 days | 30 days | 90 days | 90 days |
| Cost Center Tag | IT-Dev | IT-Test | IT-UAT | IT-Production |

## Generation Scripts

### Common Infrastructure Parameters

Generate parameter files for common infrastructure:

```bash
./scripts/generate-common-params.sh
```

Options:
- **1-4**: Generate for specific environment (dev/test/uat/prod)
- **5**: Generate for all environments at once

What it does:
- Reads global settings from `config/settings.json`
- Creates `bicep/common/parameters.{env}.json` for each environment
- Applies environment-specific overrides (SKUs, network ranges, etc.)
- Ensures consistent global values across all environments

### Integration Parameters

Generate parameter files for integrations:

```bash
./scripts/generate-integration-params.sh
```

Options:
- **1-4**: Generate for specific environment (dev/test/uat/prod)

What it does:
- Reads global settings from `config/settings.json`
- Creates simplified parameter files with only essential configuration
- Common infrastructure resources are auto-discovered using naming convention
- No need to manually specify resource IDs

## Workflow

### Initial Setup

1. **Edit global settings**:
   ```bash
   vim config/settings.json
   ```

   Update:
   - `project.customerName`
   - `project.projectName`
   - `azure.location` (if needed)
   - `naming.prefix`

2. **Generate all parameter files**:
   ```bash
   # Generate common infrastructure parameters for all environments
   echo "5" | ./scripts/generate-common-params.sh

   # Generate integration parameters for each environment
   echo "1" | ./scripts/generate-integration-params.sh  # dev
   echo "2" | ./scripts/generate-integration-params.sh  # test
   # etc.
   ```

3. **Deploy infrastructure**:
   ```bash
   ./scripts/test-deployment.sh
   ```

### Updating Configuration

When you need to change a global setting:

1. **Edit `config/settings.json`**
2. **Regenerate parameter files**:
   ```bash
   ./scripts/generate-common-params.sh
   ./scripts/generate-integration-params.sh
   ```
3. **Redeploy affected resources**

## Benefits

✅ **Single Source of Truth**: Global settings defined once in `config/settings.json`

✅ **No Duplication**: Customer name, project name, location, prefix never duplicated

✅ **Consistency**: Same values across all environments and integrations

✅ **Easy Updates**: Change once, regenerate all parameter files

✅ **Less Error-Prone**: No manual copying of values between files

✅ **Clear Separation**: Global vs environment-specific settings are clearly separated

## Settings Mapping

| Global Setting | Used In | Example Value |
|----------------|---------|---------------|
| `project.customerName` | All tags (Customer) | "Contoso" |
| `project.projectName` | All tags (Project) | "D365 Integrations" |
| `azure.location` | All deployments | "westeurope" |
| `azure.locationShort` | Resource naming | "weu" |
| `naming.prefix` | All resource names | "contoso" |
| `commonInfrastructure.storageAccount.containers` | Common storage containers | [...] |
| `commonInfrastructure.keyVault.sku` | Key Vault SKU | "standard" |
| `commonInfrastructure.network.subnets` | Subnet names | [...] |

## Example: Adding a New Environment

To add a new environment (e.g., "staging"):

1. **Update `config/subscriptions.json`**:
   ```json
   {
     "subscriptions": {
       "staging": {
         "subscriptionId": "...",
         "subscriptionName": "Staging Subscription"
       }
     }
   }
   ```

2. **Update generation scripts** to include "staging" option

3. **Generate parameters**:
   ```bash
   # Select staging option when available
   ./scripts/generate-common-params.sh
   ```

4. **Deploy**:
   ```bash
   az deployment sub create \
     --location westeurope \
     --template-file bicep/common/main.bicep \
     --parameters bicep/common/parameters.staging.json
   ```

## Troubleshooting

### Values not updating after changing settings.json

**Solution**: Regenerate parameter files:
```bash
./scripts/generate-common-params.sh
./scripts/generate-integration-params.sh
```

### Different values in different parameter files

**Cause**: Parameter files were manually edited instead of regenerated

**Solution**: Delete parameter files and regenerate from settings.json:
```bash
rm bicep/common/parameters.*.json
rm bicep/integrations/*/parameters.*.json
echo "5" | ./scripts/generate-common-params.sh
```

### Script fails with "jq not found"

**Solution**: Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Windows (using Chocolatey)
choco install jq
```

## Best Practices

1. **Never manually edit generated parameter files** - Always edit `config/settings.json` and regenerate

2. **Regenerate after every settings change** - Ensures consistency

3. **Commit both settings.json and generated parameter files** - For reproducibility

4. **Review diffs before committing** - Verify generated values are correct

5. **Use generation scripts in CI/CD** - Automate parameter generation in pipelines

6. **Document custom environment values** - If environment needs unique settings, document why
