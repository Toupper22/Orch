# Nomentia Integration Logic Apps

This directory contains the workflow definitions for the Nomentia integration Logic Apps (Consumption tier).

## Structure

Each logic app has its own directory containing:
- `workflow.json` - The Logic App workflow definition
- `scheduler-parameters-*.json` - Environment-specific parameters (if needed)

## Available Logic Apps

### 1. d365fo-nomentia-artransactions
**D365 Finance & Operations → Nomentia AR Transactions**

Retrieves AR transaction export packages from D365 F&O, transforms them using the Function App, and uploads to Nomentia SFTP.

- **Trigger**: Recurrence (every 4 hours)
- **Function**: `D365ArTransactionsTransform`
- **Flow**: D365 Export → Transform → SFTP Upload

### 2. erp-nomentia-outboundpayments
**ERP → Nomentia Outbound Payments**

Retrieves payment files from Azure Storage and uploads them to Nomentia SFTP.

- **Trigger**: Recurrence (every 6 hours)
- **Flow**: Azure Storage → SFTP Upload → Archive

### 3. nomentia-d365fo-postedbankstatements
**Nomentia → D365 Finance & Operations Posted Bank Statements**

Retrieves bank statement files from Nomentia SFTP, transforms them using the Function App, and imports to D365 F&O.

- **Trigger**: Recurrence (every 2 hours)
- **Function**: `BankStatementTransform`
- **Flow**: SFTP Download → Transform → D365 Import → Move to Processed

### 4. nomentia-erp-referencepayments
**Nomentia → ERP Reference Payments**

Retrieves reference payment files from Nomentia SFTP and stores them in Azure Storage for processing.

- **Trigger**: Recurrence (every 3 hours)
- **Flow**: SFTP Download → Azure Storage → Move to Processed

## Deployment

Logic Apps are deployed using the GitHub Actions workflow:

```bash
# Deploy all logic apps
deployLogicApps: true

# Or deploy only specific components
deployInfrastructure: false
deployFunctionApp: false
deployLogicApps: true
```

The deployment workflow automatically:
1. Loads the `workflow.json` from each directory
2. Uses the reusable Bicep template at `bicep/integrations/nomentia/single-workflow.bicep`
3. Deploys as Consumption Logic Apps with managed identity
4. Skips workflows where `workflow.json` doesn't exist

## Bicep Templates

The deployment uses reusable Bicep templates:

- **`bicep/integrations/nomentia/single-workflow.bicep`** - Deploys a single Logic App
- **`bicep/integrations/nomentia/workflow-type.bicep`** - Deploys 3 related Logic Apps (starter, process, common)

These templates are **generic and reusable** - the actual workflow logic comes from the `workflow.json` files in this directory.

## Workflow Parameters

Each workflow can reference parameters that are injected at deployment time:

```json
{
  "parameters": {
    "functionAppUrl": {
      "type": "string"
    },
    "$connections": {
      "type": "object",
      "defaultValue": {}
    }
  }
}
```

Common parameters:
- `functionAppUrl` - URL of the Function App
- `d365ExportEndpoint` - D365 F&O export API endpoint
- `d365ImportEndpoint` - D365 F&O import API endpoint
- `integrationStorageAccount` - Integration storage account name
- `$connections` - API connections (SFTP, Azure Blob, etc.)

## API Connections

Logic Apps use managed API connections for:

- **SFTP** - Nomentia SFTP server connection
- **Azure Blob Storage** - Integration storage account
- **Azure Tables** - Value and conversion lookups

These connections are configured in the Bicep templates and use managed identity authentication where possible.

## Development Workflow

1. **Edit workflow.json** - Modify the Logic App workflow definition
2. **Test locally** - Use Logic Apps Designer in Azure Portal or VS Code
3. **Commit changes** - Push to git repository
4. **Deploy** - Run GitHub Actions workflow with `deployLogicApps: true`

## Monitoring

Monitor Logic Apps in the Azure Portal:
- Resource Group: `{prefix}-{env}-nomentia-rg`
- Logic App Names: `{prefix}-{env}-nomentia-{workflowName}-logic`

View:
- Run history
- Trigger history
- Failed runs
- Performance metrics

## Error Handling

Each workflow includes error handling:
- Failed runs are retried based on trigger configuration
- Errors are logged to Application Insights
- Failed files can be moved to error folders for investigation

## Notes

- All Logic Apps use Consumption tier (pay-per-execution)
- Managed identity is used for authentication where possible
- Workflows are enabled by default (can be disabled in Bicep parameters)
- Recurrence intervals can be adjusted per environment
