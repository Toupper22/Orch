#!/bin/bash
# Bicep Template Validation Script
# This script validates all Bicep templates and runs what-if for a specified environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_info "Validating Bicep templates..."
echo ""

# Validate common infrastructure template
print_info "Building common infrastructure template..."
if az bicep build --file bicep/common/main.bicep; then
    print_success "Common infrastructure template is valid"
else
    print_error "Common infrastructure template validation failed"
    exit 1
fi

echo ""

# Validate individual modules
print_info "Validating individual modules..."
for module in bicep/modules/*.bicep; do
    module_name=$(basename "$module")
    if az bicep build --file "$module"; then
        print_success "$module_name is valid"
    else
        print_error "$module_name validation failed"
        exit 1
    fi
done

echo ""
print_success "All Bicep templates are valid!"
echo ""

# Ask if user wants to run what-if
read -p "Do you want to run what-if analysis? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Ask for environment
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
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    print_info "Running what-if analysis for $ENV environment..."
    echo ""

    az deployment sub what-if \
        --location westeurope \
        --template-file bicep/common/main.bicep \
        --parameters bicep/common/parameters.$ENV.json

    echo ""
    print_success "What-if analysis completed!"
fi
