#!/bin/bash
# Create Integration Parameters Script
# Safely creates parameter files for a new integration WITHOUT overwriting existing files

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed (brew install jq or apt-get install jq)"
    exit 1
fi

# Get integration name
echo ""
print_info "Creating parameter files for a new integration"
echo ""
read -p "Enter integration name (lowercase, e.g., 'customer-orders'): " INTEGRATION_NAME

if [ -z "$INTEGRATION_NAME" ]; then
    print_error "Integration name cannot be empty"
    exit 1
fi

# Validate integration name (lowercase, alphanumeric and hyphens only)
if ! [[ "$INTEGRATION_NAME" =~ ^[a-z0-9-]+$ ]]; then
    print_error "Integration name must be lowercase with only letters, numbers, and hyphens"
    exit 1
fi

# Check if integration directory exists
INTEGRATION_DIR="bicep/integrations/$INTEGRATION_NAME"
if [ ! -d "$INTEGRATION_DIR" ]; then
    print_warning "Integration directory does not exist: $INTEGRATION_DIR"
    read -p "Do you want to create it? (y/n): " create_dir
    if [ "$create_dir" == "y" ]; then
        mkdir -p "$INTEGRATION_DIR"
        print_success "Created directory: $INTEGRATION_DIR"
    else
        print_error "Aborting. Please create the integration directory first."
        exit 1
    fi
fi

# Get global settings
SETTINGS_FILE="config/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    print_error "Settings file not found: $SETTINGS_FILE"
    exit 1
fi

# Read global settings
PREFIX=$(jq -r '.naming.prefix' "$SETTINGS_FILE")
LOCATION=$(jq -r '.azure.location' "$SETTINGS_FILE")
LOCATION_SHORT=$(jq -r '.azure.locationShort' "$SETTINGS_FILE")
CUSTOMER=$(jq -r '.project.customerName' "$SETTINGS_FILE")
PROJECT=$(jq -r '.project.projectName' "$SETTINGS_FILE")

print_info "Using global settings from $SETTINGS_FILE:"
echo "  Prefix: $PREFIX"
echo "  Location: $LOCATION ($LOCATION_SHORT)"
echo "  Customer: $CUSTOMER"
echo "  Project: $PROJECT"
echo ""

# Function to create parameter file for an environment
create_param_file() {
    local ENV=$1
    local PARAM_FILE="$INTEGRATION_DIR/parameters.$ENV.json"

    # Check if file already exists
    if [ -f "$PARAM_FILE" ]; then
        print_warning "File already exists: $PARAM_FILE"
        read -p "Overwrite? This will DELETE any custom changes! (y/n): " overwrite
        if [ "$overwrite" != "y" ]; then
            print_info "Skipped: $PARAM_FILE"
            return
        fi
        # Create backup
        cp "$PARAM_FILE" "$PARAM_FILE.backup.$(date +%Y%m%d-%H%M%S)"
        print_warning "Backup created: $PARAM_FILE.backup.*"
    fi

    # Generate environment label for tags
    case $ENV in
        dev) ENV_LABEL="Development";;
        test) ENV_LABEL="Test";;
        uat) ENV_LABEL="UAT";;
        prod) ENV_LABEL="Production";;
    esac

    # Create the parameter file
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
      "value": "$INTEGRATION_NAME"
    },
    "tags": {
      "value": {
        "Environment": "$ENV_LABEL",
        "Customer": "$CUSTOMER",
        "Project": "$PROJECT",
        "Integration": "$INTEGRATION_NAME",
        "CostCenter": "IT-$ENV_LABEL"
      }
    },
    "serviceBusSku": {
      "value": "Standard"
    }
  }
}
EOF

    print_success "Created: $PARAM_FILE"
}

# Ask which environments to create
echo "Which environments do you want to create parameter files for?"
echo "1) dev"
echo "2) test"
echo "3) uat"
echo "4) prod"
echo "5) All environments"
read -p "Enter choice (1-5 or comma-separated like 1,2): " env_choice

# Parse the choice
case $env_choice in
    5)
        print_info "Creating parameter files for all environments..."
        create_param_file "dev"
        create_param_file "test"
        create_param_file "uat"
        create_param_file "prod"
        ;;
    *1*)
        create_param_file "dev"
        ;&
    *2*)
        create_param_file "test"
        ;&
    *3*)
        create_param_file "uat"
        ;&
    *4*)
        create_param_file "prod"
        ;;
esac

echo ""
print_success "Parameter file creation complete!"
echo ""
print_info "Next steps:"
echo "  1. Review and customize the parameter files in: $INTEGRATION_DIR"
echo "  2. Update main.bicep with your integration logic"
echo "  3. Deploy using: az deployment sub create --location $LOCATION --template-file $INTEGRATION_DIR/main.bicep --parameters $INTEGRATION_DIR/parameters.dev.json"
echo ""
print_warning "IMPORTANT: These parameter files are now YOUR responsibility to maintain."
print_warning "Do NOT re-run this script unless you want to reset to defaults."
print_warning "Always commit your parameter files to Git to track changes."
echo ""
