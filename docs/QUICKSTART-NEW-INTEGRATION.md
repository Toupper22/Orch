# Quickstart Guide: Adding a New Integration

This guide walks you through creating a new integration in the Orch-1 project.

## Prerequisites

- Common infrastructure already deployed to target environment
- Azure CLI installed and configured
- Git repository access
- Understanding of your integration requirements (queues, topics, workflows, etc.)

## Step 1: Copy the Sample Integration Template

```bash
# Navigate to integrations directory
cd bicep/integrations

# Copy the sample integration as a template
cp -r sample-integration my-new-integration

# Navigate back to project root for parameter generation
cd ../..
```

**Alternative: Use the helper script (recommended)**

```bash
# This script will create the integration directory and parameter files safely
./scripts/create-integration-params.sh

# Follow the prompts to:
# 1. Enter your integration name
# 2. Select environments to create
# 3. Script will warn before overwriting existing files
```

## Step 2: Update Integration Configuration

### 2.1 Edit main.bicep

Open `bicep/integrations/my-new-integration/main.bicep` and update:

```bicep
@description('Integration name')
param integrationName string = 'mynew'  // Change this to your integration name
```

### 2.2 Customize Resources

Update the integration resources based on your needs:

**Service Bus Queues:**
```bicep
queues: [
  {
    name: 'incoming-orders'        // Your queue name
    maxDeliveryCount: 10
    lockDuration: 'PT5M'
    defaultMessageTimeToLive: 'P7D'
  }
  // Add more queues as needed
]
```

**Service Bus Topics (if needed):**
```bicep
topics: [
  {
    name: 'customer-events'
    subscriptions: [
      {
        name: 'email-subscription'
        maxDeliveryCount: 10
      }
    ]
  }
]
```

**Storage Containers:**
```bicep
containers: [
  {
    name: 'input-files'
    publicAccess: 'None'
  }
  {
    name: 'processed-files'
    publicAccess: 'None'
  }
  // Add your containers
]
```

### 2.3 Update Parameter Files

**IMPORTANT:** Parameter files for integrations should be **manually created and maintained**. Do NOT use `generate-integration-params.sh` after you've made custom changes, as it will overwrite your modifications.

Edit `parameters.dev.json` and `parameters.test.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "prefix": {
      "value": "customer"
    },
    "environment": {
      "value": "dev"
    },
    "location": {
      "value": "swedencentral"
    },
    "locationShort": {
      "value": "sdc"
    },
    "integrationName": {
      "value": "mynew"  // Your integration name
    },
    "tags": {
      "value": {
        "Environment": "Development",
        "Integration": "MyNew",
        "CostCenter": "IT-Dev"
      }
    },
    "serviceBusSku": {
      "value": "Standard"  // Can customize: Basic, Standard, or Premium
    }
  }
}
```

**Key Customization Points:**
- `integrationName`: Unique name for your integration
- `serviceBusSku`: Adjust based on throughput requirements
- `tags`: Add integration-specific tags
- You can add custom parameters for your integration needs

Repeat for other environments (test, uat, prod).

**Version Control:** Always commit parameter file changes to Git so your customizations are tracked.

## Step 3: Create Application Code

### 3.1 Create Function App

```bash
# Navigate to source directory
cd ../../../src

# Create your integration directory
mkdir my-new-integration
cd my-new-integration

# Create Function App project
mkdir function-app
cd function-app

# Initialize .NET Function App
dotnet new func -n MyIntegration.Functions --worker-runtime dotnet-isolated --target-framework net8.0
```

### 3.2 Add Your Functions

Example Service Bus triggered function:

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MyIntegration.Functions
{
    public class ProcessOrderFunction
    {
        private readonly ILogger<ProcessOrderFunction> _logger;

        public ProcessOrderFunction(ILogger<ProcessOrderFunction> logger)
        {
            _logger = logger;
        }

        [Function("ProcessOrder")]
        public async Task Run(
            [ServiceBusTrigger("incoming-orders", Connection = "ServiceBusConnection")]
            string message)
        {
            _logger.LogInformation("Processing order: {message}", message);

            // Your processing logic here

            _logger.LogInformation("Order processed successfully");
        }
    }
}
```

### 3.3 Create Logic App Workflow

```bash
# Navigate back to integration directory
cd ..

# Create Logic App workflow directory
mkdir -p logic-app/OrderOrchestrator
cd logic-app/OrderOrchestrator
```

Create `workflow.json`:

```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "triggers": {
      "When_a_message_is_received": {
        "type": "ServiceBusTrigger",
        "inputs": {
          "queueName": "incoming-orders",
          "connection": "servicebus"
        }
      }
    },
    "actions": {
      "Call_Function": {
        "type": "Http",
        "inputs": {
          "method": "POST",
          "uri": "@parameters('functionAppUrl')",
          "body": "@triggerBody()"
        }
      }
    }
  }
}
```

## Step 4: Create GitHub Workflow

Copy and update the deployment workflow:

```bash
cd ../../../.github/workflows
cp deploy-sample-integration.yml deploy-my-new-integration.yml
```

Edit `deploy-my-new-integration.yml`:

```yaml
name: Deploy MyNew Integration

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - dev
          - test
          - uat
          - prod
      whatIf:
        description: 'Run what-if deployment (preview changes without deploying)'
        required: false
        type: boolean
        default: false

# ... rest of the workflow

      - name: Deploy Infrastructure
        id: deploy
        uses: azure/arm-deploy@v2
        with:
          scope: subscription
          region: swedencentral
          template: ./bicep/integrations/my-new-integration/main.bicep
          parameters: ./bicep/integrations/my-new-integration/parameters.${{ inputs.environment }}.json
          deploymentName: my-new-integration-${{ inputs.environment }}-${{ github.run_number }}
          deploymentMode: Incremental
          failOnStdErr: false

      - name: Build Function App
        run: |
          cd src/my-new-integration/function-app
          dotnet restore
          dotnet build --configuration Release
          dotnet publish --configuration Release --output ./publish
```

## Step 5: Deploy Your Integration

### 5.1 Deploy Common Infrastructure (if not already deployed)

```bash
# Via GitHub Actions
# Go to Actions → Deploy Common Infrastructure → Run workflow → Select environment
```

Or via Azure CLI:

```bash
az deployment sub create \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json
```

### 5.2 Deploy Your Integration

```bash
# Via GitHub Actions
# Go to Actions → Deploy MyNew Integration → Run workflow → Select environment
```

Or via Azure CLI:

```bash
az deployment sub create \
  --location swedencentral \
  --template-file bicep/integrations/my-new-integration/main.bicep \
  --parameters bicep/integrations/my-new-integration/parameters.dev.json
```

## Step 6: Verify Deployment

### 6.1 Check Azure Resources

```bash
# List all resources in your integration resource group
az resource list --resource-group customer-dev-mynew-rg --output table
```

Expected resources:
- ✅ Service Bus Namespace
- ✅ Service Bus Queue(s)/Topic(s)
- ✅ Function Storage Account
- ✅ Archive Storage Account
- ✅ Function App
- ✅ Logic App
- ✅ Key Vault

### 6.2 Verify Key Vault Secrets

```bash
# List secrets in integration Key Vault
az keyvault secret list --vault-name <your-keyvault-name> --output table
```

Expected secrets:
- ✅ FunctionStorageAccountKey
- ✅ ArchiveStorageAccountKey
- ✅ FunctionStorageConnectionString
- ✅ ArchiveStorageConnectionString

### 6.3 Test Function App

```bash
# Get Function App URL
az functionapp show \
  --resource-group customer-dev-mynew-rg \
  --name <function-app-name> \
  --query defaultHostName -o tsv

# Check Function App logs
az functionapp log tail \
  --resource-group customer-dev-mynew-rg \
  --name <function-app-name>
```

### 6.4 Test Service Bus

```bash
# Send a test message to your queue
az servicebus queue send \
  --resource-group customer-dev-mynew-rg \
  --namespace-name <servicebus-name> \
  --name incoming-orders \
  --body "Test message"
```

## Step 7: Access Storage Accounts

### From Azure Portal
1. Navigate to Azure Portal
2. Go to your storage account
3. Access will work from IP 217.149.56.100 or from within the VNet

### From Azure Storage Explorer
1. Download Azure Storage Explorer
2. Connect using your Azure account
3. Or use storage account key from Key Vault

### From Code (using Managed Identity)
```csharp
// Function App automatically uses managed identity
var blobServiceClient = new BlobServiceClient(
    new Uri($"https://{storageAccountName}.blob.core.windows.net"),
    new DefaultAzureCredential()
);
```

## Step 8: Monitor Your Integration

### Application Insights
```bash
# View Application Insights data
az monitor app-insights component show \
  --resource-group customer-dev-common-rg \
  --app <app-insights-name>
```

### Check Alerts
- Email alerts configured for: kalle.korhonen@efima.com
- Alert types: Availability drops, Exception spikes

## Troubleshooting

### Issue: Storage Account Access Denied

**Solution:** Verify you're accessing from allowed IP or VNet:
```bash
az storage account show \
  --resource-group customer-dev-mynew-rg \
  --name <storage-account-name> \
  --query networkRuleSet
```

### Issue: Function App Not Starting

**Solution:** Check Application Insights logs:
```bash
az monitor app-insights events show \
  --app <app-insights-name> \
  --type exceptions \
  --start-time 1h
```

### Issue: Service Bus Connection Errors

**Solution:** Verify managed identity has permissions:
```bash
az role assignment list \
  --assignee <managed-identity-id> \
  --resource-group customer-dev-mynew-rg \
  --output table
```

## Common Customizations

### Add Custom App Settings

Edit your integration's `main.bicep`:

```bicep
appSettings: [
  {
    name: 'ServiceBusConnection__fullyQualifiedNamespace'
    value: '${serviceBus.outputs.name}.servicebus.windows.net'
  }
  {
    name: 'MyCustomSetting'
    value: 'MyCustomValue'
  }
]
```

### Add More Storage Tables

```bicep
tables: [
  {
    name: 'Values'
  }
  {
    name: 'Conversions'
  }
  {
    name: 'MyCustomTable'  // Add your table
  }
]
```

### Change Storage Account SKU

For production, use geo-redundant storage:

```bicep
skuName: 'Standard_GRS'  // Instead of Standard_LRS
```

## Best Practices

1. **Naming Convention**
   - Use lowercase for integration names
   - Keep names short and descriptive
   - Follow pattern: `customer-{env}-{integration}-{resource}`

2. **Resource Organization**
   - One integration = One resource group
   - Shared resources in common resource group
   - Integration-specific secrets in integration Key Vault

3. **Parameter File Management** ⚠️
   - **CRITICAL:** Parameter files are integration-specific and should be manually maintained
   - Use `create-integration-params.sh` ONLY for initial creation
   - Never re-run parameter generation scripts after customizing files
   - Always commit parameter files to Git
   - Document any custom parameters in your integration README
   - Use meaningful commit messages when changing parameters

4. **Environment Promotion**
   - Always deploy to dev first
   - Test thoroughly before promoting to test/uat
   - Use what-if mode for production deployments
   - Review changes before actual deployment
   - Keep parameter files in sync across environments (with environment-specific values)

5. **Monitoring**
   - Check Application Insights regularly
   - Set up custom alerts for your integration
   - Monitor Service Bus queue depths
   - Track Function App execution metrics

6. **Security**
   - Never commit secrets to Git
   - Use Key Vault for all sensitive data
   - Leverage managed identity for authentication
   - Review network access rules regularly

## Next Steps

- [ ] Review [Azure Well-Architected Framework](../docs/WELL-ARCHITECTED-REVIEW.md)
- [ ] Set up additional monitoring dashboards
- [ ] Configure auto-scaling for production
- [ ] Implement comprehensive testing
- [ ] Document your integration workflow

## Support

For questions or issues:
1. Check existing documentation in `/docs`
2. Review sample integration for examples
3. Contact the DevOps team
4. Review Azure documentation

---

**Document Version:** 1.0
**Last Updated:** 2025-10-22
**Maintained By:** Infrastructure Team
