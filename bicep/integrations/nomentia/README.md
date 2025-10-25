# Nomentia Integration

This integration connects Nomentia banking services with D365 Finance & Operations and other ERP systems for processing bank statements, payments, and AR transactions.

## Overview

The Nomentia integration deploys:

- **Function App**: Azure Function (Efima.IL.Nomentia) that handles data transformation for:
  - Bank statements (Nomentia → D365 FO)
  - AR Transactions (D365 FO → Nomentia)
  - Reference payments (Nomentia → ERP)
  - Outbound payments (ERP → Nomentia)

- **Storage Accounts**:
  - Function Storage: Runtime storage for the Function App
  - Integration Storage: Data storage with containers for:
    - `bank-statements`: Incoming bank statement files
    - `ar-transactions`: AR transaction data
    - `payments`: Payment files (inbound/outbound)
    - `archive`: Archived processed files

- **Service Bus**: Message queues for asynchronous processing:
  - `nomentia-inbound`: Messages from Nomentia
  - `nomentia-outbound`: Messages to Nomentia

- **Key Vault**: Stores integration secrets and connection strings

## Architecture

```
Nomentia APIs
    ↓
Service Bus (nomentia-inbound)
    ↓
Azure Function (Data Transformation)
    ↓
Integration Storage / Service Bus (nomentia-outbound)
    ↓
D365 FO / ERP Systems
```

## Deployment

### Prerequisites

Before deploying this integration, ensure the common infrastructure is deployed:
- Common resource group
- VNet with integration subnet
- App Service Plan
- Managed Identity
- Application Insights

### Deploy via GitHub Actions

1. Navigate to **Actions** → **Deploy Nomentia Integration**
2. Click **Run workflow**
3. Select target environment: `dev`, `test`, `uat`, or `prod`
4. (Optional) Check **what-if** to preview changes without deploying
5. Click **Run workflow**

### Deploy via Azure CLI

```bash
# Set environment
ENVIRONMENT="dev"

# Set subscription
SUBSCRIPTION_ID=$(jq -r ".subscriptions.${ENVIRONMENT}.subscriptionId" config/subscriptions.json)
az account set --subscription "$SUBSCRIPTION_ID"

# Deploy infrastructure
az deployment sub create \
  --location swedencentral \
  --template-file ./bicep/modules/standardIntegration.bicep \
  --parameters ./bicep/integrations/nomentia/parameters.${ENVIRONMENT}.json \
  --name "nomentia-integration-${ENVIRONMENT}-$(date +%s)"

# Build and deploy function app
cd src/Efima.IL.Nomentia
dotnet publish --configuration Release --output ./publish
cd publish
zip -r ../function-app.zip .
cd ..

# Get function app name from deployment output
FUNCTION_APP_NAME=$(az deployment sub show \
  --name "nomentia-integration-${ENVIRONMENT}-latest" \
  --query properties.outputs.functionAppName.value -o tsv)

RESOURCE_GROUP=$(az deployment sub show \
  --name "nomentia-integration-${ENVIRONMENT}-latest" \
  --query properties.outputs.resourceGroupName.value -o tsv)

# Deploy function app code
az functionapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_APP_NAME \
  --src function-app.zip
```

## Configuration

### Environment-Specific Parameters

Each environment has its own parameter file:
- `parameters.dev.json` - Development
- `parameters.test.json` - Test
- `parameters.uat.json` - UAT
- `parameters.prod.json` - Production

Key parameters:
- `prefix`: Customer/project prefix (e.g., "edmo")
- `environment`: Environment name
- `location`: Azure region
- `locationShort`: Short region code (e.g., "sdc")
- `integrationName`: Always "nomentia"
- `serviceBusSku`: Service Bus tier (Basic/Standard/Premium)
- `tags`: Resource tags for governance

### Function App Settings

The Function App is configured with:
- `.NET 8.0 Isolated` runtime
- VNet integration for secure connectivity
- Managed Identity for authentication
- Application Insights for monitoring

Key app settings:
- `ServiceBusConnection__fullyQualifiedNamespace`: Service Bus endpoint
- `FunctionStorage__accountName`: Function storage account
- `IntegrationStorage__accountName`: Integration data storage
- `KeyVaultUri`: Key Vault for secrets

## Data Flows

### 1. Bank Statements (Nomentia → D365 FO)
- Nomentia posts bank statement files to Integration Storage (`bank-statements` container)
- Function App processes and transforms to D365 FO format
- Transformed data sent to D365 FO via API/Service Bus

### 2. AR Transactions (D365 FO → Nomentia)
- D365 FO sends AR transaction data
- Function App transforms to Nomentia format
- Output stored in Integration Storage (`ar-transactions` container)
- Data sent to Nomentia API

### 3. Reference Payments (Nomentia → ERP)
- Payment reference files from Nomentia
- Function App processes payment data
- Forwarded to ERP system

### 4. Outbound Payments (ERP → Nomentia)
- ERP system initiates payment
- Function App formats for Nomentia
- Sent via Service Bus outbound queue

## Monitoring

### Application Insights
All function executions are logged to Application Insights:
- Navigate to the common Application Insights resource
- Filter by `cloud_RoleName` containing "nomentia"
- View:
  - Function execution traces
  - Performance metrics
  - Failures and exceptions

### Key Vault Access Logs
Monitor secret access:
- Navigate to Key Vault → Diagnostic settings
- View access logs for compliance

### Storage Metrics
Monitor file processing:
- Check blob container metrics
- Review transaction counts
- Alert on error container activity

## Troubleshooting

### Function App Not Starting
1. Check App Service Plan has capacity
2. Verify VNet integration is working
3. Review Application Insights logs
4. Ensure Managed Identity has proper RBAC roles

### Cannot Access Storage
1. Verify IP address is in storage firewall rules
2. Check VNet integration subnet is allowed
3. Confirm Managed Identity has "Storage Blob Data Contributor" role

### Service Bus Connection Issues
1. Verify Managed Identity has Service Bus roles assigned
2. Check Service Bus namespace is accessible
3. Review network rules on Service Bus

## Security

### Network Security
- All storage accounts use network ACLs (deny by default)
- VNet integration for private connectivity
- Only specified IP addresses can access storage

### Authentication
- Managed Identity used for all Azure resource access
- No connection strings in app settings
- Service Bus uses AAD authentication

### Secrets Management
- All secrets stored in Key Vault
- Function App accesses via Managed Identity
- Soft delete and purge protection enabled (prod)

## Resource Naming Convention

Resources follow the naming pattern:
```
{prefix}-{environment}-{integrationName}-{resourceType}
```

Examples for `edmo-dev-nomentia`:
- Resource Group: `edmo-dev-nomentia-rg`
- Function App: `edmo-dev-sdc-nomentia-func`
- Service Bus: `edmodevnomentiasb` (no hyphens)
- Storage: `edmodevsdcnomentiast` (no hyphens)
- Key Vault: `edmodevsdcnomentiakv` (no hyphens)

## Related Integrations

This integration may work alongside:
- Sample Integration (for reference architecture)
- Other ERP integrations in the platform

## Support

For issues or questions:
1. Check Application Insights for error details
2. Review deployment logs in GitHub Actions
3. Verify configuration in parameter files
4. Contact the integration team
