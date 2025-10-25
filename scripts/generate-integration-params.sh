#!/bin/bash
# Generate Integration Parameters Script
# Generates simplified integration parameter files based on naming convention

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
read -p "Enter choice (1-4): " env_choice

case $env_choice in
    1) ENV="dev";;
    2) ENV="test";;
    3) ENV="uat";;
    4) ENV="prod";;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

print_info "Generating parameters for $ENV environment..."

# Get all values from global settings
SETTINGS_FILE="config/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    print_warning "Settings file not found: $SETTINGS_FILE"
    exit 1
fi

# Read global settings
PREFIX=$(jq -r '.naming.prefix' "$SETTINGS_FILE")
LOCATION=$(jq -r '.azure.location' "$SETTINGS_FILE")
LOCATION_SHORT=$(jq -r '.azure.locationShort' "$SETTINGS_FILE")
CUSTOMER=$(jq -r '.project.customerName' "$SETTINGS_FILE")
PROJECT=$(jq -r '.project.projectName' "$SETTINGS_FILE")

# Expected common resource group name (for verification)
COMMON_RG="${PREFIX}-${ENV}-common-rg"

print_info "Integration will reference common infrastructure:"
echo "  Common Resource Group: $COMMON_RG"
echo "  App Service Plan:      ${PREFIX}-${ENV}-${LOCATION_SHORT}-plan"
echo "  Managed Identity:      ${PREFIX}${ENV}${LOCATION_SHORT}id"
echo "  Virtual Network:       ${PREFIX}-${ENV}-${LOCATION_SHORT}-vnet"
echo "  Integration Subnet:    integration-subnet"
echo ""

# Check if Azure CLI is available and verify common infrastructure exists
if command -v az &> /dev/null; then
    if jq -e ".subscriptions.$ENV" config/subscriptions.json > /dev/null 2>&1; then
        SUBSCRIPTION_ID=$(jq -r ".subscriptions.$ENV.subscriptionId" config/subscriptions.json)
        az account set --subscription "$SUBSCRIPTION_ID" 2>/dev/null || true

        if az group show --name "$COMMON_RG" &> /dev/null; then
            print_success "Verified common resource group exists"
        else
            print_warning "Common resource group '$COMMON_RG' not found"
            print_warning "Please deploy common infrastructure first: ./scripts/test-deployment.sh"
        fi
    fi
fi

# Create parameter file
PARAM_FILE="bicep/integrations/sample-integration/parameters.$ENV.json"

# Generate environment label for tags
case $ENV in
    dev) ENV_LABEL="Development";;
    test) ENV_LABEL="Test";;
    uat) ENV_LABEL="UAT";;
    prod) ENV_LABEL="Production";;
esac

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
    "integrationName": {
      "value": "sample"
    },
    "tags": {
      "value": {
        "Environment": "$ENV_LABEL",
        "Customer": "$CUSTOMER",
        "Project": "$PROJECT",
        "Integration": "Sample Integration"
      }
    },
    "serviceBusSku": {
      "value": "Standard"
    }
  }
}
EOF

print_success "Parameter file generated: $PARAM_FILE"
echo ""
print_info "Parameter file contains only essential values."
print_info "Common infrastructure resources will be auto-discovered using naming convention."
echo ""
print_info "You can now deploy the integration:"
echo "  cd bicep/integrations/sample-integration"
echo "  az deployment sub create \\"
echo "    --location $LOCATION \\"
echo "    --template-file main.bicep \\"
echo "    --parameters parameters.$ENV.json"
