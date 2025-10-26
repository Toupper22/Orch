# Standard Integration Template Variations

## Overview

This directory contains multiple variations of the standard integration template, each optimized for specific integration patterns. This approach provides:

- **Safety**: Changes to one template won't affect other integrations
- **Clarity**: Each template clearly shows what infrastructure it creates
- **Simplicity**: Less conditional logic, easier to understand
- **Maintainability**: Easier to test and evolve each pattern independently

## Template Variations

### 1. `standardIntegration.bicep` (Original)

**Use Case**: Service Bus-based integrations with Azure Functions

**Includes**:
- Service Bus namespace and queues
- Function App with App Service Plan integration
- Function storage account (with file share)
- Integration storage account
- Key Vault for secrets
- Optional API connections (Blob, Table)
- RBAC assignments for Service Bus and Storage

**Best For**:
- Message-driven integrations
- Event-based processing
- Complex data transformations requiring custom code
- High-volume, reliable message processing

**Examples**: Nomentia, SEPA integrations

---

### 2. `standardIntegration-sftp.bicep` (SFTP Variant)

**Use Case**: SFTP-to-Blob integrations using Logic Apps only

**Includes**:
- Integration storage account (for blob storage)
- Key Vault for secrets
- SFTP API connection
- Blob API connection
- RBAC assignments for Storage

**Does NOT Include**:
- Service Bus (not needed)
- Function App (Logic Apps handle all processing)
- Function storage account (no functions to deploy)

**Best For**:
- File transfer from SFTP to Azure Blob Storage
- Simple file-based integrations
- Scheduled file polling
- No custom code required

**Parameters**:
```bicep
// SFTP connection
sftpHost: 'sftp.example.com'
sftpPort: 22
sftpUsername: 'username'
sftpPassword: 'password' // or use SSH key
sftpRootFolder: '/files'

// Storage
integrationStorageContainers: [
  'input-files', 'processed', 'errors'
]
```

**Security Note**: SFTP credentials should be stored in Azure Key Vault and referenced in the deployment pipeline. Do not commit passwords or SSH keys to source control. The deployment workflow should retrieve these secrets from Key Vault at deployment time.

**Example Integration Structure**:
```
bicep/integrations/my-sftp-integration/
├── parameters.dev.json              # Infrastructure parameters
├── parameters.test.json
├── parameters.prod.json
├── logicapps/
│   └── file-processor/
│       ├── starter.json            # Scheduled SFTP poller
│       └── process.json            # File processor
└── workflow-type.bicep             # Logic App deployment
```

---

## Shared Modules

To avoid duplication, common components are extracted into reusable modules:

### API Connection Modules

Located in: `bicep/modules/shared/apiConnections/`

#### Blob Storage (`blob.bicep`)
```bicep
module blobConnection './shared/apiConnections/blob.bicep' = {
  params: {
    connectionName: 'my-blob-conn'
    storageAccountResourceGroup: resourceGroup().name
    storageAccountName: 'mystorageaccount'
  }
}
```

#### SFTP (`sftp.bicep`)
```bicep
module sftpConnection './shared/apiConnections/sftp.bicep' = {
  params: {
    connectionName: 'my-sftp-conn'
    sftpHost: 'sftp.example.com'
    sftpUsername: 'user'
    sftpPassword: 'pass' // or sftpSshPrivateKey
  }
}
```

#### Table Storage (`table.bicep`)
```bicep
module tableConnection './shared/apiConnections/table.bicep' = {
  params: {
    connectionName: 'my-table-conn'
    storageAccountResourceGroup: resourceGroup().name
    storageAccountName: 'mystorageaccount'
  }
}
```

#### Service Bus (`servicebus.bicep`)
```bicep
module sbConnection './shared/apiConnections/servicebus.bicep' = {
  params: {
    connectionName: 'my-sb-conn'
    serviceBusNamespace: 'myservicebus'
    serviceBusResourceGroup: resourceGroup().name
  }
}
```

### Other Shared Modules

Located in: `bicep/modules/`

- `storageAccount.bicep` - Storage account with containers/tables
- `keyVault.bicep` - Key Vault with access policies
- `functionApp.bicep` - Function App configuration
- `serviceBus.bicep` - Service Bus namespace and queues
- `naming.bicep` - Consistent resource naming
- `rbacAssignment.bicep` - RBAC role assignments

---

## Choosing the Right Template

| Integration Pattern | Template to Use | Reason |
|-------------------|----------------|--------|
| Service Bus + Azure Functions | `standardIntegration.bicep` | Message processing with custom code |
| SFTP → Blob Storage | `standardIntegration-sftp.bicep` | File transfer, Logic Apps only |
| HTTP APIs only | `standardIntegration-http.bicep` (future) | RESTful integrations |
| SQL Database integration | `standardIntegration-sql.bicep` (future) | Database-driven workflows |
| Custom requirements | Create custom `main.bicep` | Full control over infrastructure |

---

## Creating a New Template Variation

If you need a new pattern (e.g., SQL-based integration):

### 1. Create the Template

```bash
cp bicep/modules/standardIntegration.bicep \
   bicep/modules/standardIntegration-sql.bicep
```

### 2. Remove Unneeded Components

- Remove Service Bus if not needed
- Remove Function App if using Logic Apps only
- Remove Function Storage if no functions

### 3. Add Pattern-Specific Components

```bicep
// Example: Add SQL API Connection
module sqlApiConnection './shared/apiConnections/sql.bicep' = {
  params: {
    connectionName: '${prefix}-${environment}-${integrationName}-sql-conn'
    sqlServer: sqlServerName
    sqlDatabase: sqlDatabaseName
    sqlUsername: sqlUsername
    sqlPassword: sqlPassword
  }
}
```

### 4. Update Parameters

Add pattern-specific parameters:
```bicep
@description('SQL Server name')
param sqlServerName string

@description('SQL Database name')
param sqlDatabaseName string
```

### 5. Update Outputs

```bicep
@description('SQL API Connection ID')
output sqlApiConnectionId string = sqlApiConnection.outputs.id
```

### 6. Document the Pattern

Add section to this README explaining:
- Use case
- What's included/excluded
- Best practices
- Example usage

---

## Migration Guide

### From Custom main.bicep to Template Variation

If you have an existing integration with custom `main.bicep`:

**Option 1: Keep Custom Template**
- No changes needed
- Continue using your custom template
- Good for unique integrations

**Option 2: Migrate to Standard Variation**
1. Identify which variation matches your pattern
2. Create parameter files for the variation
3. Test deployment in dev environment
4. Deploy with `what-if` mode first
5. Switch deployment workflow to use new template

**Option 3: Create New Variation**
- If your pattern is reusable
- Follow "Creating a New Template Variation" above
- Benefits future integrations with same pattern

---

## Best Practices

### 1. Template Selection
- Choose the simplest template that meets your needs
- Don't add Service Bus if you don't need message queuing
- Don't add Function Apps if Logic Apps can handle all processing

### 2. Parameter Organization
```json
{
  "parameters": {
    // Common parameters (all templates)
    "integrationName": { "value": "my-integration" },
    "environment": { "value": "dev" },

    // Pattern-specific parameters
    "sftpHost": { "value": "sftp.example.com" },
    "integrationStorageContainers": {
      "value": ["input", "processed", "errors"]
    }
  }
}
```

### 3. Security
- Store sensitive parameters (passwords, keys) in Key Vault
- Reference Key Vault in template parameters:
```bicep
sftpCredentialsKeyVaultName: 'my-keyvault'
sftpPasswordSecretName: 'SftpPassword'
```

### 4. Testing
- Always test new templates in dev environment first
- Use `az deployment sub what-if` before production deployments
- Verify API connections are properly authorized

### 5. Documentation
- Document which template variation your integration uses
- Include setup instructions in integration README
- Note any manual steps (API connection authorization)

---

## Future Template Variations

Planned variations based on common patterns:

- `standardIntegration-http.bicep` - HTTP/REST API integrations
- `standardIntegration-sql.bicep` - SQL database integrations
- `standardIntegration-minimal.bicep` - Storage + Functions only
- `standardIntegration-hybrid.bicep` - Mix of Functions + Logic Apps

---

## Questions?

- Template structure: See individual template files
- Shared modules: See `bicep/modules/shared/`
- API connections: See `bicep/modules/shared/apiConnections/`
- Example integrations: See `bicep/integrations/*/`
