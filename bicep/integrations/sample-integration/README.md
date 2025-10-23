# Sample Integration - Consumption Logic Apps

Multi-workflow integration demonstrating reusable patterns with Azure Consumption Logic Apps.

## Architecture Overview

This integration uses **Consumption Logic Apps** (serverless, pay-per-execution) organized into multiple **workflow types**. Each workflow type follows a three-stage pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                     Workflow Type                            │
│  (e.g., statements, reference-payments, sepa-payments)      │
└─────────────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌─────▼─────┐   ┌────▼─────┐
    │ Starter │───▶│  Process   │──▶│  Common  │
    │Logic App│    │ Logic App  │   │Logic App │
    └─────────┘    └────────────┘   └──────────┘
         │               │                │
    Recurrence      Transforms         Archives
    Trigger         Data & Stores      & Logs
```

### Three-Stage Pattern

1. **Starter Logic App**: Scheduled trigger (recurrence) that checks source (SFTP, API, etc.) for new items and triggers Process for each
2. **Process Logic App**: Processes individual items, transforms data, stores results, and calls Common with status
3. **Common Logic App**: Handles archiving successful files, error handling, logging to Azure Tables, and notifications

### Current Workflow Types

- **statements**: Bank statement processing (60-minute recurrence)
- **reference-payments**: Reference payment processing (30-minute recurrence)
- **sepa-payments**: SEPA payment XML processing (120-minute recurrence)

## Folder Structure

```
bicep/integrations/sample-integration/
├── workflow-type.bicep              # Deploys 3 Logic Apps for one workflow type
├── logicapps/
│   ├── statements/
│   │   ├── starter.json             # Workflow definition
│   │   ├── process.json             # Workflow definition
│   │   ├── common.json              # Workflow definition
│   │   └── parameters.dev.json      # Deployment parameters
│   ├── reference-payments/
│   │   ├── starter.json
│   │   ├── process.json
│   │   ├── common.json
│   │   └── parameters.dev.json
│   └── sepa-payments/
│       ├── starter.json
│       ├── process.json
│       ├── common.json
│       └── parameters.dev.json
└── README.md
```

## Deployment

### Option 1: Deploy Individual Workflow Type (Recommended)

Use dedicated GitHub Actions workflows to deploy only what changed:

**Via GitHub Actions:**
- Go to Actions → Select workflow:
  - "Deploy Sample Integration - Statements"
  - "Deploy Sample Integration - Reference Payments"
  - "Deploy Sample Integration - SEPA Payments"
- Select environment (dev/test/uat/prod)
- Run workflow

**Via Azure CLI:**
```bash
# Set subscription
SUBSCRIPTION_ID=$(jq -r '.subscriptions.dev.subscriptionId' config/subscriptions.json)
az account set --subscription "$SUBSCRIPTION_ID"

# Deploy single workflow type
az deployment sub create \
  --location swedencentral \
  --template-file ./bicep/integrations/sample-integration/workflow-type.bicep \
  --parameters ./bicep/integrations/sample-integration/logicapps/statements/parameters.dev.json \
    starterWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/statements/starter.json | jq -c)" \
    processWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/statements/process.json | jq -c)" \
    commonWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/statements/common.json | jq -c)" \
  --name sample-integration-statements-dev
```

### Option 2: Deploy All Workflow Types

Deploy all workflow types at once (typically only for initial setup):

```bash
# Deploy all workflow types sequentially
for workflow in statements reference-payments sepa-payments; do
  az deployment sub create \
    --location swedencentral \
    --template-file ./bicep/integrations/sample-integration/workflow-type.bicep \
    --parameters ./bicep/integrations/sample-integration/logicapps/${workflow}/parameters.dev.json \
      starterWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/${workflow}/starter.json | jq -c)" \
      processWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/${workflow}/process.json | jq -c)" \
      commonWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/${workflow}/common.json | jq -c)" \
    --name sample-integration-${workflow}-dev
done
```

## Adding New Workflow Types

1. **Create folder** under `logicapps/`:
   ```bash
   mkdir -p bicep/integrations/sample-integration/logicapps/new-workflow-type
   ```

2. **Create workflow definitions**:
   - `starter.json` - Recurrence trigger, iterate source items, call process
   - `process.json` - HTTP trigger, transform data, store results, call common
   - `common.json` - HTTP trigger, archive/error handling, logging

3. **Create parameter file** `parameters.dev.json`:
   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
     "contentVersion": "1.0.0.0",
     "parameters": {
       "prefix": { "value": "edmo" },
       "environment": { "value": "dev" },
       "location": { "value": "swedencentral" },
       "locationShort": { "value": "sdc" },
       "integrationName": { "value": "sample" },
       "workflowType": { "value": "new-workflow-type" },
       "tags": {
         "value": {
           "Environment": "Development",
           "Customer": "efimademo",
           "Project": "demoproject"
         }
       }
     }
   }
   ```

4. **Create GitHub Actions workflow** `.github/workflows/deploy-sample-integration-new-workflow-type.yml`:
   - Copy existing workflow file
   - Update workflow name
   - Update file paths to new workflow type folder

5. **Deploy**:
   ```bash
   az deployment sub create \
     --location swedencentral \
     --template-file ./bicep/integrations/sample-integration/workflow-type.bicep \
     --parameters ./bicep/integrations/sample-integration/logicapps/new-workflow-type/parameters.dev.json \
       starterWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/new-workflow-type/starter.json | jq -c)" \
       processWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/new-workflow-type/process.json | jq -c)" \
       commonWorkflowDefinition="$(cat bicep/integrations/sample-integration/logicapps/new-workflow-type/common.json | jq -c)" \
     --name sample-integration-new-workflow-type-dev
   ```

## Logic App Naming Convention

Logic Apps are named: `{prefix}-{env}-{integration}-{workflowType}-{stage}-logic`

Examples:
- `edmo-dev-sample-statements-starter-logic`
- `edmo-dev-sample-statements-process-logic`
- `edmo-dev-sample-statements-common-logic`
- `edmo-dev-sample-reference-payments-starter-logic`
- `edmo-dev-sample-sepa-payments-starter-logic`

## API Connections Used

All Logic Apps use Managed Identity authentication with the following API connections:

- **SFTP**: File retrieval and archiving
- **Azure Table Storage**: Logging and audit trail
- **Office 365 Outlook**: Error notifications via email
- **Azure Blob Storage**: Storing transformed data

These connections are deployed with the common infrastructure and referenced by resource ID.

## Benefits of This Pattern

1. **Separation of Concerns**: Each Logic App has a single responsibility
2. **Reusability**: Common Logic App is shared across all workflow types
3. **Scalability**: Consumption tier scales automatically per workflow type
4. **Cost Efficiency**: Pay only for executions, no idle App Service Plan
5. **Independent Deployment**: Deploy only changed workflow types
6. **Maintainability**: Workflow definitions are separate JSON files
7. **Monitoring**: Each Logic App can be monitored independently

## Monitoring

Each Logic App can be monitored in the Azure Portal:

1. Navigate to Logic App resource
2. View **Runs history** for execution details
3. Check **Run Details** for step-by-step execution
4. View **Metrics** for performance and error rates
5. Query **Log Analytics** for aggregated logs across all workflow types

## Troubleshooting

### Logic App Not Triggering

- Check recurrence trigger schedule in starter.json
- Verify Logic App is **Enabled** in Azure Portal
- Check API connection authentication (Managed Identity permissions)

### Workflow Execution Failures

1. Open Logic App in Azure Portal
2. Click on failed run in **Runs history**
3. Expand failed step to see error details
4. Common issues:
   - SFTP connection timeout → Check network connectivity
   - Table Storage access denied → Verify Managed Identity has "Storage Table Data Contributor" role
   - Email send failure → Check Office 365 connection status

### Deployment Errors

- Ensure common infrastructure is deployed first
- Validate JSON workflow definitions with `jq . file.json`
- Check parameter file has correct `workflowType` value
- Verify API connections exist in common infrastructure

## Common Infrastructure Dependencies

This integration requires these resources from common infrastructure:

- **Managed Identity**: For API connection authentication
- **API Connections**: SFTP, Azure Tables, Office 365, Blob Storage
- **Storage Account**: For blob containers
- **Log Analytics Workspace**: For diagnostics logs
- **Virtual Network**: For secure connectivity (if needed)

Deploy common infrastructure first using:
```bash
./scripts/test-deployment.sh
```

## Further Customization

- **Add more workflow types**: Follow "Adding New Workflow Types" section
- **Modify schedules**: Update recurrence trigger in starter.json
- **Change processing logic**: Edit process.json workflow definition
- **Add more actions**: Update workflow definitions with additional steps
- **Environment-specific configs**: Create parameters.{env}.json for test/uat/prod

## Related Documentation

- Consumption Logic Apps: [Microsoft Docs](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-overview)
- Managed Identity authentication: [Microsoft Docs](https://learn.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity)
- Workflow definition language: [Microsoft Docs](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language)
