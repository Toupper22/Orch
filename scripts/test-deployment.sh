#!/bin/bash
# Infrastructure Deployment Testing Script
# Validates and previews Bicep deployments before actual deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install it first (brew install jq)."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_header "Infrastructure Deployment Testing"

# Ask for environment
echo "Select environment to test:"
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
        print_error "Invalid choice"
        exit 1
        ;;
esac

print_info "Testing deployment for: $ENV environment"
echo ""

# Get subscription ID from config
SUBSCRIPTION_ID=$(jq -r ".subscriptions.$ENV.subscriptionId" config/subscriptions.json)
SUBSCRIPTION_NAME=$(jq -r ".subscriptions.$ENV.subscriptionName" config/subscriptions.json)

if [ "$SUBSCRIPTION_ID" == "null" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    print_error "Subscription ID not found for $ENV environment in config/subscriptions.json"
    exit 1
fi

print_info "Target Subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Set the subscription
print_info "Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"
CURRENT_SUB=$(az account show --query name -o tsv)
print_success "Active subscription: $CURRENT_SUB"
echo ""

# Step 1: Validate Bicep syntax
print_header "Step 1: Bicep Syntax Validation"

print_info "Building main template..."
if az bicep build --file bicep/common/main.bicep --stdout > /dev/null 2>&1; then
    print_success "Main template syntax is valid"
else
    print_error "Main template has syntax errors"
    az bicep build --file bicep/common/main.bicep 2>&1 | grep -i "error"
    exit 1
fi

print_info "Validating all modules..."
MODULE_COUNT=0
for module in bicep/modules/*.bicep; do
    module_name=$(basename "$module")
    if az bicep build --file "$module" --stdout > /dev/null 2>&1; then
        print_success "$module_name"
        ((MODULE_COUNT++))
    else
        print_error "$module_name has errors"
        exit 1
    fi
done

print_success "All $MODULE_COUNT modules are valid"
echo ""

# Step 2: Validate deployment
print_header "Step 2: Deployment Validation"

print_info "Validating deployment against Azure..."
if az deployment sub validate \
    --location swedencentral \
    --template-file bicep/common/main.bicep \
    --parameters bicep/common/parameters.$ENV.json \
    --query "properties.provisioningState" -o tsv > /dev/null 2>&1; then
    print_success "Deployment validation passed"
else
    print_error "Deployment validation failed"
    print_info "Running validation again with detailed output..."
    az deployment sub validate \
        --location swedencentral \
        --template-file bicep/common/main.bicep \
        --parameters bicep/common/parameters.$ENV.json
    exit 1
fi
echo ""

# Step 3: What-If Analysis
print_header "Step 3: What-If Analysis (Dry Run)"

print_info "Running what-if analysis to preview changes..."
print_warning "This may take 1-2 minutes..."
echo ""

WHAT_IF_OUTPUT=$(az deployment sub what-if \
    --location swedencentral \
    --template-file bicep/common/main.bicep \
    --parameters bicep/common/parameters.$ENV.json \
    --result-format FullResourcePayloads 2>&1)

echo "$WHAT_IF_OUTPUT"
echo ""

# Parse what-if results
CREATE_COUNT=$(echo "$WHAT_IF_OUTPUT" | grep -c "^  + " || true)
MODIFY_COUNT=$(echo "$WHAT_IF_OUTPUT" | grep -c "^  ~ " || true)
DELETE_COUNT=$(echo "$WHAT_IF_OUTPUT" | grep -c "^  - " || true)
IGNORE_COUNT=$(echo "$WHAT_IF_OUTPUT" | grep -c "^  * " || true)

print_header "What-If Summary"
echo "Resources to be created:  $CREATE_COUNT"
echo "Resources to be modified: $MODIFY_COUNT"
echo "Resources to be deleted:  $DELETE_COUNT"
echo "Resources unchanged:      $IGNORE_COUNT"
echo ""

# Step 4: Cost Estimation (optional)
print_header "Step 4: Cost Estimation"
print_info "For cost estimation, use Azure Pricing Calculator:"
print_info "https://azure.microsoft.com/pricing/calculator/"
echo ""

print_info "Estimated resources for $ENV:"
echo "  - Virtual Network: Free"
echo "  - NAT Gateway: ~\$0.045/hour + \$0.045/GB processed"
echo "  - Public IP (Standard): ~\$0.005/hour"
echo "  - Key Vault: \$0.03 per 10,000 operations"
echo "  - Storage Account (Standard LRS): ~\$0.018/GB/month"
echo "  - App Service Plan:"

APP_SERVICE_SKU=$(jq -r '.parameters.appServicePlanSku.value' bicep/common/parameters.$ENV.json)
case $APP_SERVICE_SKU in
    "Y1")
        echo "    Y1 (Consumption): Pay per execution (~\$0.20/million executions)"
        ;;
    "EP1")
        echo "    EP1 (Elastic Premium): ~\$180/month"
        ;;
    "EP2")
        echo "    EP2 (Elastic Premium): ~\$360/month"
        ;;
    "EP3")
        echo "    EP3 (Elastic Premium): ~\$720/month"
        ;;
esac
echo ""

# Final Summary
print_header "Testing Complete"

if [ $CREATE_COUNT -gt 0 ] || [ $MODIFY_COUNT -gt 0 ]; then
    print_warning "Changes will be made to your Azure subscription!"
    echo ""
    echo "Next steps:"
    echo "1. Review the what-if output above carefully"
    echo "2. Verify the changes match your expectations"
    echo "3. To deploy via GitHub Actions:"
    echo "   - Go to Actions → Deploy Common Infrastructure"
    echo "   - Select environment: $ENV"
    echo "   - Run workflow"
    echo ""
    echo "4. To deploy via Azure CLI:"
    echo "   az deployment sub create \\"
    echo "     --location swedencentral \\"
    echo "     --template-file bicep/common/main.bicep \\"
    echo "     --parameters bicep/common/parameters.$ENV.json \\"
    echo "     --name common-infra-$ENV-\$(date +%Y%m%d-%H%M%S)"
else
    print_success "No changes detected - infrastructure is up to date"
fi

echo ""
print_success "All tests passed successfully!"
