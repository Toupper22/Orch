# Infrastructure Testing Guide

This guide explains how to test and validate your infrastructure deployments before making actual changes to Azure.

## Table of Contents

- [Testing Methods](#testing-methods)
- [Quick Start](#quick-start)
- [Testing Levels](#testing-levels)
- [Using the Test Script](#using-the-test-script)
- [Manual Testing](#manual-testing)
- [GitHub Actions Testing](#github-actions-testing)
- [Understanding What-If Output](#understanding-what-if-output)
- [Troubleshooting](#troubleshooting)

## Testing Methods

There are three ways to test infrastructure deployments:

| Method | Description | Use Case |
|--------|-------------|----------|
| **Automated Script** | `scripts/test-deployment.sh` | Comprehensive testing with all steps |
| **Validation Script** | `scripts/validate-bicep.sh` | Quick syntax and validation check |
| **Manual Commands** | Azure CLI commands | Custom testing scenarios |
| **GitHub Actions** | What-If mode in workflow | Testing in CI/CD pipeline |

## Quick Start

### Option 1: Automated Testing (Recommended)

```bash
# Run comprehensive test for an environment
./scripts/test-deployment.sh
```

This script will:
1. ✅ Validate Bicep syntax
2. ✅ Validate deployment against Azure
3. ✅ Run what-if analysis (dry run)
4. ✅ Provide cost estimates
5. ✅ Show deployment summary

### Option 2: Quick Validation

```bash
# Quick syntax validation only
./scripts/validate-bicep.sh
```

## Testing Levels

### Level 1: Syntax Validation

Validates that your Bicep files are syntactically correct.

```bash
# Validate main template
az bicep build --file bicep/common/main.bicep

# Validate all modules
for module in bicep/modules/*.bicep; do
    az bicep build --file "$module"
done
```

**What it checks:**
- Bicep syntax errors
- Invalid parameter types
- Missing required parameters
- Reference errors

**Does NOT check:**
- Azure resource availability
- Naming conflicts
- RBAC permissions
- Actual deployment feasibility

### Level 2: Deployment Validation

Validates the deployment against Azure without creating resources.

```bash
# Set the correct subscription
SUBSCRIPTION_ID=$(jq -r '.subscriptions.dev.subscriptionId' config/subscriptions.json)
az account set --subscription "$SUBSCRIPTION_ID"

# Validate deployment
az deployment sub validate \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json
```

**What it checks:**
- All Level 1 checks
- Resource provider registration
- API version availability
- Parameter validity
- Deployment scope permissions

**Does NOT check:**
- Resource name conflicts
- Quota limits
- Actual changes to existing resources

### Level 3: What-If Analysis (Dry Run)

Preview exactly what changes will be made to your infrastructure.

```bash
az deployment sub what-if \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json \
  --result-format FullResourcePayloads
```

**What it checks:**
- All Level 1 & 2 checks
- Existing resources that will be modified
- New resources that will be created
- Resources that will be deleted
- Property-level changes

**This is your "dry run" - no resources are created or modified.**

## Using the Test Script

### Running the Full Test

```bash
./scripts/test-deployment.sh
```

**Interactive prompts:**
1. Select environment (dev/test/uat/prod)
2. Script automatically:
   - Sets correct subscription
   - Validates syntax
   - Validates deployment
   - Runs what-if analysis
   - Shows cost estimates

### Understanding the Output

```
═══════════════════════════════════════════════════════════
  Step 1: Bicep Syntax Validation
═══════════════════════════════════════════════════════════

ℹ Building main template...
✓ Main template syntax is valid
ℹ Validating all modules...
✓ naming.bicep
✓ keyVault.bicep
✓ storageAccount.bicep
...
✓ All 9 modules are valid

═══════════════════════════════════════════════════════════
  Step 2: Deployment Validation
═══════════════════════════════════════════════════════════

ℹ Validating deployment against Azure...
✓ Deployment validation passed

═══════════════════════════════════════════════════════════
  Step 3: What-If Analysis (Dry Run)
═══════════════════════════════════════════════════════════

ℹ Running what-if analysis to preview changes...
⚠ This may take 1-2 minutes...

Resource and property changes are indicated with these symbols:
  - Delete
  + Create
  ~ Modify
  * Ignore

The deployment will update the following scope:

Scope: /subscriptions/xxxxx

  + Microsoft.Network/publicIPAddresses/contoso-dev-sdc-pip
  + Microsoft.Network/natGateways/contoso-dev-sdc-nat
  + Microsoft.Network/virtualNetworks/contoso-dev-sdc-vnet
  + Microsoft.KeyVault/vaults/edmodsctkv
  + Microsoft.Storage/storageAccounts/edmodscst
  ...

═══════════════════════════════════════════════════════════
  What-If Summary
═══════════════════════════════════════════════════════════

Resources to be created:  8
Resources to be modified: 0
Resources to be deleted:  0
Resources unchanged:      0
```

## Manual Testing

### Test Specific Environment

```bash
# Set subscription
SUBSCRIPTION_ID=$(jq -r '.subscriptions.dev.subscriptionId' config/subscriptions.json)
az account set --subscription "$SUBSCRIPTION_ID"

# Run what-if for dev
az deployment sub what-if \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json
```

### Test Parameter Changes

```bash
# Edit parameters file
vim bicep/common/parameters.dev.json

# Test the changes
./scripts/test-deployment.sh
```

### Test Module Individually

```bash
# Build and validate a specific module
az bicep build --file bicep/modules/virtualNetwork.bicep

# Decompile to see generated ARM template
az bicep build --file bicep/modules/virtualNetwork.bicep --stdout
```

## GitHub Actions Testing

### Using What-If Mode

1. Go to **Actions** → **Deploy Common Infrastructure**
2. Click **Run workflow**
3. Select:
   - **Environment**: dev (or test/uat/prod)
   - **What-If**: ✅ **Checked**
4. Click **Run workflow**

The workflow will:
- Validate the templates
- Run what-if analysis
- Display results in job summary
- **NOT deploy any resources**

### Viewing What-If Results

After the workflow completes:
1. Click on the workflow run
2. Go to the **preview** job
3. Expand **Run What-If Analysis** step
4. Review the changes

## Understanding What-If Output

### Change Symbols

| Symbol | Meaning | Description |
|--------|---------|-------------|
| `+` | Create | New resource will be created |
| `~` | Modify | Existing resource will be modified |
| `-` | Delete | Resource will be deleted |
| `*` | Ignore | Resource exists but won't be modified |

### Example Output

```
Scope: /subscriptions/xxxxx

  + Microsoft.Network/virtualNetworks/contoso-dev-sdc-vnet [2023-09-01]

      location:            "swedencentral"
      properties.addressSpace.addressPrefixes: [
        "10.0.0.0/16"
      ]
      properties.subnets: [
        {
          name:                   "integration-subnet"
          properties.addressPrefix: "10.0.1.0/24"
          properties.natGateway.id: "/subscriptions/.../natGateways/contoso-dev-sdc-nat"
        }
      ]
```

**How to read this:**
- `+` means this Virtual Network will be **created**
- Location will be `swedencentral`
- Address space will be `10.0.0.0/16`
- One subnet will be created with NAT Gateway attached

### Modify Example

```
  ~ Microsoft.KeyVault/vaults/edmodsctkv [2023-07-01]
    ~ properties.softDeleteRetentionInDays: 7 => 90
```

**How to read this:**
- `~` means this Key Vault will be **modified**
- The soft delete retention will change from 7 to 90 days
- No other properties will change

## Testing Checklist

Before deploying to any environment:

- [ ] Run syntax validation (`./scripts/validate-bicep.sh`)
- [ ] Run what-if analysis (`./scripts/test-deployment.sh`)
- [ ] Review all resources that will be created
- [ ] Review all resources that will be modified
- [ ] Verify no unexpected deletions
- [ ] Check resource naming matches expectations
- [ ] Verify correct subscription is targeted
- [ ] Review estimated costs
- [ ] Test in lower environment first (dev → test → uat → prod)
- [ ] Get approval for production changes

## Common Testing Scenarios

### Scenario 1: First Deployment

```bash
# Test dev deployment
./scripts/test-deployment.sh
# Select: 1 (dev)

# Review output - should show all resources as "Create"
# Deploy if output looks correct
```

### Scenario 2: Update Existing Infrastructure

```bash
# Make changes to parameter files
vim bicep/common/parameters.dev.json

# Test changes
./scripts/test-deployment.sh
# Select: 1 (dev)

# Review output - should show specific "Modify" changes
```

### Scenario 3: Test All Environments

```bash
# Test each environment
for env in dev test uat prod; do
    echo "Testing $env..."
    az deployment sub what-if \
        --location swedencentral \
        --template-file bicep/common/main.bicep \
        --parameters bicep/common/parameters.$env.json
done
```

### Scenario 4: Breaking Change Detection

```bash
# Test a destructive change
./scripts/test-deployment.sh

# Look for "-" (Delete) symbols in output
# If resources will be deleted, review carefully!
```

## Troubleshooting

### Issue: "Subscription not found"

**Solution**: Update `config/subscriptions.json` with correct subscription ID.

```bash
# List your subscriptions
az account list --output table

# Update config/subscriptions.json with correct ID
```

### Issue: "Resource provider not registered"

**Solution**: Register the required providers:

```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.ManagedIdentity

# Check registration status
az provider show --namespace Microsoft.Network --query "registrationState"
```

### Issue: "Location not available for subscription"

**Solution**: Check available locations:

```bash
az account list-locations --output table

# Update location in parameter files if needed
```

### Issue: "What-if takes too long"

This is normal. What-if analysis can take 1-3 minutes because Azure needs to:
- Evaluate all resource dependencies
- Check existing resources
- Calculate property-level changes

**Tips:**
- Be patient
- Run during off-peak hours
- Use `--result-format ResourceIdOnly` for faster but less detailed results

### Issue: "What-if shows unexpected changes"

**Possible causes:**
1. Someone manually changed resources in Azure Portal
2. Previous deployment used different parameters
3. Azure API defaults have changed

**Solution:**
```bash
# Compare current state with template
az deployment sub what-if \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.dev.json \
  --result-format FullResourcePayloads

# Review each change carefully
```

## Best Practices

### 1. Always Test Before Deploying

```bash
# DON'T do this
az deployment sub create ...  # Direct deployment

# DO this instead
az deployment sub what-if ...  # Test first
# Review output
az deployment sub create ...   # Deploy after review
```

### 2. Test in Lower Environments First

```
dev → test → uat → prod
```

Always deploy to dev first, validate, then promote through environments.

### 3. Use What-If for Code Reviews

Include what-if output in Pull Requests:

```bash
# Generate what-if for PR
./scripts/test-deployment.sh > what-if-output.txt

# Add to PR description
```

### 4. Automate Testing in CI

Add validation to your CI pipeline:

```yaml
# In your CI workflow
- name: Validate Infrastructure
  run: ./scripts/validate-bicep.sh
```

### 5. Keep What-If Results

```bash
# Save what-if output for audit trail
az deployment sub what-if \
  --location swedencentral \
  --template-file bicep/common/main.bicep \
  --parameters bicep/common/parameters.prod.json \
  > what-if-prod-$(date +%Y%m%d-%H%M%S).txt
```

## Summary

| Test Type | Command | Purpose | Time |
|-----------|---------|---------|------|
| **Syntax** | `./scripts/validate-bicep.sh` | Check Bicep syntax | ~10s |
| **Validation** | `az deployment sub validate` | Validate against Azure | ~30s |
| **What-If** | `az deployment sub what-if` | Preview changes (DRY RUN) | ~2min |
| **Full Test** | `./scripts/test-deployment.sh` | All of the above | ~3min |

**Remember**: What-if is your **dry run** - it shows exactly what will happen without making any changes!
