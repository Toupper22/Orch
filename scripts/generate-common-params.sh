#!/bin/bash
# Generate Common Infrastructure Parameters Script
# Generates common infrastructure parameter files from global settings

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Check prerequisites
check_required_commands jq || exit 1

# Get environment
echo "Select environment:"
echo "1) dev"
echo "2) test"
echo "3) uat"
echo "4) prod"
echo "5) all"
read -p "Enter choice (1-5): " env_choice

case $env_choice in
    1) ENVIRONMENTS=("dev");;
    2) ENVIRONMENTS=("test");;
    3) ENVIRONMENTS=("uat");;
    4) ENVIRONMENTS=("prod");;
    5) ENVIRONMENTS=("dev" "test" "uat" "prod");;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Read global settings
SETTINGS_FILE="config/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    print_warning "Settings file not found: $SETTINGS_FILE"
    exit 1
fi

print_info "Reading global settings from: $SETTINGS_FILE"

# Read global values
PREFIX=$(jq -r '.naming.prefix' "$SETTINGS_FILE")
LOCATION=$(jq -r '.azure.location' "$SETTINGS_FILE")
LOCATION_SHORT=$(jq -r '.azure.locationShort' "$SETTINGS_FILE")
CUSTOMER=$(jq -r '.project.customerName' "$SETTINGS_FILE")
PROJECT=$(jq -r '.project.projectName' "$SETTINGS_FILE")

# Read common infrastructure settings
DEPLOY_LOG_ANALYTICS=$(jq -r '.commonInfrastructure.logAnalyticsWorkspace.enabled' "$SETTINGS_FILE")
DEPLOY_KEY_VAULT=$(jq -r '.commonInfrastructure.keyVault.enabled' "$SETTINGS_FILE")
DEPLOY_STORAGE=$(jq -r '.commonInfrastructure.storageAccount.enabled' "$SETTINGS_FILE")
DEPLOY_APP_PLAN=$(jq -r '.commonInfrastructure.appServicePlan.enabled' "$SETTINGS_FILE")
DEPLOY_MANAGED_ID=$(jq -r '.commonInfrastructure.managedIdentity.enabled' "$SETTINGS_FILE")
DEPLOY_SERVICE_BUS=$(jq -r '.commonInfrastructure.serviceBus.enabled' "$SETTINGS_FILE")
DEPLOY_NETWORK=$(jq -r '.commonInfrastructure.network.enabled' "$SETTINGS_FILE")
DEPLOY_NAT=$(jq -r '.commonInfrastructure.network.natGateway.enabled' "$SETTINGS_FILE")

LOG_ANALYTICS_SKU=$(jq -r '.commonInfrastructure.logAnalyticsWorkspace.sku' "$SETTINGS_FILE")
LOG_ANALYTICS_RETENTION=$(jq -r '.commonInfrastructure.logAnalyticsWorkspace.retentionInDays' "$SETTINGS_FILE")
LOG_ANALYTICS_QUOTA=$(jq -r '.commonInfrastructure.logAnalyticsWorkspace.dailyQuotaGb' "$SETTINGS_FILE")

KEY_VAULT_SKU=$(jq -r '.commonInfrastructure.keyVault.sku' "$SETTINGS_FILE")
KEY_VAULT_RETENTION=$(jq -r '.commonInfrastructure.keyVault.softDeleteRetentionInDays' "$SETTINGS_FILE")

STORAGE_SKU=$(jq -r '.commonInfrastructure.storageAccount.sku' "$SETTINGS_FILE")
STORAGE_CONTAINERS=$(jq -c '.commonInfrastructure.storageAccount.containers' "$SETTINGS_FILE")
STORAGE_TABLES=$(jq -c '.commonInfrastructure.storageAccount.tables' "$SETTINGS_FILE")

APP_PLAN_KIND=$(jq -r '.commonInfrastructure.appServicePlan.kind' "$SETTINGS_FILE")

SERVICE_BUS_SKU=$(jq -r '.commonInfrastructure.serviceBus.sku' "$SETTINGS_FILE")
SERVICE_BUS_CAPACITY=$(jq -r '.commonInfrastructure.serviceBus.capacity' "$SETTINGS_FILE")

DEPLOY_API_CONNECTIONS=$(jq -r '.commonInfrastructure.apiConnections.enabled' "$SETTINGS_FILE")

NAT_TIMEOUT=$(jq -r '.commonInfrastructure.network.natGateway.idleTimeoutInMinutes' "$SETTINGS_FILE")
SUBNETS=$(jq -c '.commonInfrastructure.network.subnets' "$SETTINGS_FILE")

ENABLE_DIAGNOSTICS=$(jq -r '.security.enableDiagnostics' "$SETTINGS_FILE")
EXTERNAL_LOG_WORKSPACE_ID=$(jq -r '.security.externalLogAnalyticsWorkspaceId' "$SETTINGS_FILE")

# Process each environment
for ENV in "${ENVIRONMENTS[@]}"; do
    print_info "Generating parameters for $ENV environment..."

    # Environment-specific values
    case $ENV in
        dev)
            ENV_LABEL="Development"
            APP_PLAN_SKU=$(jq -r '.commonInfrastructure.appServicePlan.sku.dev' "$SETTINGS_FILE")
            COST_CENTER="IT-Dev"
            VNET_PREFIX='["10.0.0.0/16"]'
            SUBNET_DEV=$(echo "$SUBNETS" | jq '.[0].addressPrefix = "10.0.1.0/24" | .[1].addressPrefix = "10.0.2.0/24"')
            ;;
        test)
            ENV_LABEL="Test"
            APP_PLAN_SKU=$(jq -r '.commonInfrastructure.appServicePlan.sku.test' "$SETTINGS_FILE")
            COST_CENTER="IT-Test"
            VNET_PREFIX='["10.1.0.0/16"]'
            SUBNET_DEV=$(echo "$SUBNETS" | jq '.[0].addressPrefix = "10.1.1.0/24" | .[1].addressPrefix = "10.1.2.0/24"')
            ;;
        uat)
            ENV_LABEL="UAT"
            APP_PLAN_SKU=$(jq -r '.commonInfrastructure.appServicePlan.sku.uat' "$SETTINGS_FILE")
            COST_CENTER="IT-UAT"
            VNET_PREFIX='["10.2.0.0/16"]'
            SUBNET_DEV=$(echo "$SUBNETS" | jq '.[0].addressPrefix = "10.2.1.0/24" | .[1].addressPrefix = "10.2.2.0/24"')
            ;;
        prod)
            ENV_LABEL="Production"
            APP_PLAN_SKU=$(jq -r '.commonInfrastructure.appServicePlan.sku.prod' "$SETTINGS_FILE")
            COST_CENTER="IT-Production"
            VNET_PREFIX='["10.3.0.0/16"]'
            SUBNET_DEV=$(echo "$SUBNETS" | jq '.[0].addressPrefix = "10.3.1.0/24" | .[1].addressPrefix = "10.3.2.0/24"')
            ;;
    esac

    # Create parameter file
    PARAM_FILE="bicep/common/parameters.$ENV.json"

    cat > "$PARAM_FILE" <<EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "prefix": {
      "value": "$PREFIX"
    },
    "environment": {
      "value": "$ENV"
    },
    "location": {
      "value": "$LOCATION"
    },
    "locationShort": {
      "value": "$LOCATION_SHORT"
    },
    "tags": {
      "value": {
        "Environment": "$ENV_LABEL",
        "Customer": "$CUSTOMER",
        "Project": "$PROJECT",
        "CostCenter": "$COST_CENTER"
      }
    },
    "deployKeyVault": {
      "value": $DEPLOY_KEY_VAULT
    },
    "deployStorageAccount": {
      "value": $DEPLOY_STORAGE
    },
    "deployAppServicePlan": {
      "value": $DEPLOY_APP_PLAN
    },
    "deployManagedIdentity": {
      "value": $DEPLOY_MANAGED_ID
    },
    "deployLogAnalyticsWorkspace": {
      "value": $DEPLOY_LOG_ANALYTICS
    },
    "logAnalyticsWorkspaceSku": {
      "value": "$LOG_ANALYTICS_SKU"
    },
    "logAnalyticsRetentionInDays": {
      "value": $LOG_ANALYTICS_RETENTION
    },
    "logAnalyticsDailyQuotaGb": {
      "value": $LOG_ANALYTICS_QUOTA
    },
    "keyVaultSku": {
      "value": "$KEY_VAULT_SKU"
    },
    "keyVaultSoftDeleteRetentionInDays": {
      "value": $KEY_VAULT_RETENTION
    },
    "storageAccountSku": {
      "value": "$STORAGE_SKU"
    },
    "storageContainers": {
      "value": $STORAGE_CONTAINERS
    },
    "storageTables": {
      "value": $STORAGE_TABLES
    },
    "appServicePlanSku": {
      "value": "$APP_PLAN_SKU"
    },
    "appServicePlanKind": {
      "value": "$APP_PLAN_KIND"
    },
    "deployServiceBus": {
      "value": $DEPLOY_SERVICE_BUS
    },
    "serviceBusSku": {
      "value": "$SERVICE_BUS_SKU"
    },
    "serviceBusCapacity": {
      "value": $SERVICE_BUS_CAPACITY
    },
    "deployApiConnections": {
      "value": $DEPLOY_API_CONNECTIONS
    },
    "enableDiagnostics": {
      "value": $ENABLE_DIAGNOSTICS
    },
    "externalLogAnalyticsWorkspaceId": {
      "value": "$EXTERNAL_LOG_WORKSPACE_ID"
    },
    "deployVirtualNetwork": {
      "value": $DEPLOY_NETWORK
    },
    "deployNatGateway": {
      "value": $DEPLOY_NAT
    },
    "vnetAddressPrefixes": {
      "value": $VNET_PREFIX
    },
    "subnets": {
      "value": $SUBNET_DEV
    },
    "natGatewayIdleTimeoutInMinutes": {
      "value": $NAT_TIMEOUT
    }
  }
}
EOF

    print_success "Parameter file generated: $PARAM_FILE"
done

echo ""
print_info "All parameter files generated from global settings!"
print_info "Source: $SETTINGS_FILE"
echo ""
print_info "To deploy common infrastructure:"
echo "  ./scripts/test-deployment.sh"
