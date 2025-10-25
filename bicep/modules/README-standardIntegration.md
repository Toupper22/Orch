# Standard Integration Template

## Overview

The `standardIntegration.bicep` template is a **unified, parameterized template** for deploying all integration infrastructure. Instead of maintaining separate Bicep files for each integration (SEPA, Nomentia, etc.), all integrations now use this single template with different parameter files.

## Benefits

✅ **Consistency** - All integrations follow the same pattern
✅ **Reduced Duplication** - One template instead of N copies
✅ **Easier Maintenance** - Bug fixes apply to all integrations
✅ **Simpler Onboarding** - Adding a new integration = creating a parameters file

## Usage

### Creating a New Integration

1. **Create a parameters file**: `bicep/integrations/{integration-name}/parameters.{env}.json`
2. **Reference the standard template** in your GitHub Actions workflow
3. **Deploy!**

### Example Parameter File

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "integrationName": { "value": "myintegration" },
    "serviceBusQueues": {
      "value": [
        {
          "name": "my-inbound-queue",
          "maxDeliveryCount": 10,
          "lockDuration": "PT5M",
          "defaultMessageTimeToLive": "P7D"
        }
      ]
    },
    "integrationStorageContainers": {
      "value": [
        { "name": "input-files", "publicAccess": "None" },
        { "name": "processed-files", "publicAccess": "None" }
      ]
    },
    "enableBlobApiConnection": { "value": true },
    "enableTableApiConnection": { "value": false }
  }
}
```

## Parameters Reference

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prefix` | string | Customer/project prefix |
| `environment` | string | Environment (dev/test/uat/prod) |
| `location` | string | Azure region |
| `locationShort` | string | Region short code (e.g., "sdc") |
| `integrationName` | string | Name of the integration |

### Service Bus Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `serviceBusSku` | string | Standard | SKU (Basic/Standard/Premium) |
| `serviceBusQueues` | array | [] | Array of queue configurations |

**Queue Configuration Schema:**
```json
{
  "name": "queue-name",
  "maxDeliveryCount": 10,
  "lockDuration": "PT5M",
  "defaultMessageTimeToLive": "P7D"
}
```

### Storage Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `storageFirewallDefault` | string | Allow | Firewall default action (Allow/Deny) |
| `functionStorageContainers` | array | [] | Containers for Function App storage |
| `functionStorageTables` | array | [] | Tables for Function App storage |
| `integrationStorageContainers` | array | [] | Containers for integration data |
| `integrationStorageTables` | array | [] | Tables for integration data |
| `integrationStorageInstance` | string | int | Storage suffix ("arc"=archive, "int"=integration) |

**Container/Table Schema:**
```json
// Container
{
  "name": "container-name",
  "publicAccess": "None"
}

// Table
{
  "name": "TableName"
}
```

### Function App Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `functionAppSettings` | array | [] | Additional app settings beyond defaults |

**App Settings Schema:**
```json
{
  "name": "SETTING_NAME",
  "value": "setting-value"
}
```

**Default App Settings (automatically added):**
- `ServiceBusConnection__fullyQualifiedNamespace`
- `IntegrationStorage__accountName`
- `KeyVaultUri`

### API Connections (for Logic Apps)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableBlobApiConnection` | bool | false | Create Azure Blob API connection |
| `enableTableApiConnection` | bool | false | Create Azure Table API connection |

## Outputs

The template provides these outputs:

| Output | Description |
|--------|-------------|
| `resourceGroupName` | Integration resource group name |
| `serviceBusName` | Service Bus namespace name |
| `queueNames` | Array of created queue names |
| `functionAppName` | Function App name |
| `functionStorageName` | Function App storage account name |
| `integrationStorageName` | Integration data storage account name |
| `integrationKeyVaultName` | Integration Key Vault name |
| `integrationKeyVaultUri` | Integration Key Vault URI |
| `blobApiConnectionId` | Blob API connection ID (if enabled) |
| `blobApiConnectionName` | Blob API connection name (if enabled) |
| `tableApiConnectionId` | Table API connection ID (if enabled) |
| `tableApiConnectionName` | Table API connection name (if enabled) |

## Deployed Resources

For each integration, the template deploys:

### Core Infrastructure
- **Resource Group** - Integration-specific resource group
- **Key Vault** - For integration secrets
- **Service Bus Namespace** - With configured queues
- **Function App** - .NET isolated runtime
- **Function Storage Account** - For Function App runtime
- **Integration Storage Account** - For integration data

### Security & Networking
- **RBAC Roles** - Service Bus, Storage, Function App contributor
- **VNet Integration** - Function App connected to common VNet
- **Firewall Rules** - Storage account network restrictions
- **Managed Identity** - Using common managed identity

### Optional Resources
- **Blob API Connection** - If `enableBlobApiConnection` is true
- **Table API Connection** - If `enableTableApiConnection` is true

## Migration from Legacy Templates

If you have an existing integration using a custom `main.bicep`:

1. **Backup your old file**: `mv main.bicep main.bicep.legacy`
2. **Create a parameter file** with your configuration
3. **Update GitHub Actions** to reference `bicep/modules/standardIntegration.bicep`
4. **Test with what-if** before deploying

## Known Limitations

- **Storage Queues**: Not yet supported (storage account module limitation)
- **Custom RBAC roles**: Use standard roles only

## Examples

See existing integrations for examples:
- **SEPA**: Uses API connections, archive storage
- **Nomentia**: Uses integration data storage

## Questions?

Contact the platform team or check the [main documentation](../../README.md).
