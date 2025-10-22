# Sample Integration

End-to-end integration demonstrating the complete pattern: Service Bus → Logic App → Function App → Storage

## Quick Start

### 1. Deploy Common Infrastructure First

```bash
./scripts/test-deployment.sh
# Select environment and deploy
```

### 2. Generate Integration Parameters

```bash
./scripts/generate-integration-params.sh
# Select environment (1-4)
```

This creates a simplified `parameters.{env}.json` file. Common infrastructure resources are automatically discovered using the naming convention.

### 3. Deploy Integration

**Via GitHub Actions:**
- Go to Actions → Deploy Sample Integration
- Select environment
- Run workflow

**Via Azure CLI:**
```bash
# Set subscription
SUBSCRIPTION_ID=$(jq -r '.subscriptions.dev.subscriptionId' config/subscriptions.json)
az account set --subscription "$SUBSCRIPTION_ID"

# Deploy infrastructure
az deployment sub create \
  --location swedencentral \
  --template-file main.bicep \
  --parameters parameters.dev.json \
  --name sample-integration-dev
```

## Architecture

```
Service Bus Queue (incoming-messages)
         ↓
Logic App (MessageOrchestrator)
         ├→ Function App (Transform Message)
         ├→ Storage (transformed-messages/)
         └→ Storage (errors/) [on failure]
```

## Components

- **Service Bus**: Message queue
- **Function App**: C# .NET 8 message transformer
- **Logic App**: Workflow orchestrator
- **Storage**: Stores transformed messages
- **Uses Shared**: App Service Plan, VNet, Managed Identity

## Documentation

See [SAMPLE-INTEGRATION.md](../../../docs/SAMPLE-INTEGRATION.md) for:
- Complete architecture
- Deployment guide
- Testing instructions
- Customization guide
- Troubleshooting

## Source Code

- Function App: `src/sample-integration/function-app/`
- Logic App Workflow: `src/sample-integration/logic-app/`

## Parameters

The parameter file includes only essential configuration:
- Prefix, environment, location
- Integration name
- Tags
- Service Bus SKU

Common infrastructure resources (App Service Plan, Managed Identity, VNet, etc.) are automatically discovered using the naming convention - no need to manually specify them!
