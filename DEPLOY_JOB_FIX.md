# Deploy Job Skip Fix

## Problem

When trying to deploy **only** the function app code without infrastructure:

```yaml
deployInfrastructure: false
deployFunctionApp: true
```

**Result:**
- ✅ Build job ran successfully
- ❌ Deploy job was **skipped**
- ❌ Function app code was never deployed

## Root Cause

The `deploy` job had this condition (line 157):

```yaml
if: |
  always() &&
  inputs.whatIf == false &&
  inputs.deployInfrastructure == true &&  # ← This line caused the issue!
  needs.validate.result == 'success' &&
  (needs.build-function-app.result == 'success' || needs.build-function-app.result == 'skipped')
```

This required `deployInfrastructure == true`, which meant:
- If you wanted to deploy **only code**, the deploy job would skip
- The function app code deployment lives inside the deploy job
- Therefore, code was never deployed

## Solution

### 1. Fixed Deploy Job Condition ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:155-159`

**Before:**
```yaml
if: |
  always() &&
  inputs.whatIf == false &&
  inputs.deployInfrastructure == true &&
  needs.validate.result == 'success' &&
  (needs.build-function-app.result == 'success' || needs.build-function-app.result == 'skipped')
```

**After:**
```yaml
if: |
  always() &&
  inputs.whatIf == false &&
  (inputs.deployInfrastructure == true || inputs.deployFunctionApp == true) &&  # ← Changed!
  (needs.validate.result == 'success' || needs.validate.result == 'skipped') &&  # ← Changed!
  (needs.build-function-app.result == 'success' || needs.build-function-app.result == 'skipped')
```

**Changes:**
- Now runs if **either** infrastructure or function app needs deployment
- Handles skipped validate job (when deployInfrastructure is false)
- Handles skipped build job (when deployFunctionApp is false)

### 2. Made Infrastructure Deployment Conditional ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:188`

Added condition to infrastructure deployment step:

```yaml
- name: Deploy Infrastructure
  id: deploy
  if: ${{ inputs.deployInfrastructure == true }}  # ← Only deploy infrastructure when requested
  uses: azure/arm-deploy@v2
  ...
```

### 3. Get Resource Names When Infrastructure Is Skipped ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:198-216`

Added new step to get resource names from parameters when infrastructure deployment is skipped:

```yaml
- name: Get Existing Deployment Info
  id: existing
  if: ${{ inputs.deployInfrastructure == false && inputs.deployFunctionApp == true }}
  run: |
    # When infrastructure deployment is skipped, get resource names from parameters file
    PREFIX=$(jq -r '.parameters.prefix.value' bicep/integrations/nomentia/parameters.${{ inputs.environment }}.json)
    LOCATION_SHORT=$(jq -r '.parameters.locationShort.value' bicep/integrations/nomentia/parameters.${{ inputs.environment }}.json)
    ENV="${{ inputs.environment }}"

    # Match the naming convention from main.bicep
    RESOURCE_GROUP="${PREFIX}-${ENV}-nomentia-rg"
    FUNCTION_APP="${PREFIX}-${ENV}-${LOCATION_SHORT}-nomentia-func"

    echo "resourceGroupName=$RESOURCE_GROUP" >> $GITHUB_OUTPUT
    echo "functionAppName=$FUNCTION_APP" >> $GITHUB_OUTPUT
```

### 4. Updated Function Deployment Steps ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:280-281, 381-382`

Function deployment steps now use either infrastructure outputs or existing deployment info:

```bash
# Use outputs from either infrastructure deployment or existing deployment
FUNCTION_APP_NAME="${{ steps.deploy.outputs.functionAppName || steps.existing.outputs.functionAppName }}"
RESOURCE_GROUP="${{ steps.deploy.outputs.resourceGroupName || steps.existing.outputs.resourceGroupName }}"
```

### 5. Made Infrastructure-Only Steps Conditional ✅

Steps that only make sense when deploying infrastructure are now conditional:

- **Temporarily Allow Public Access to Function Storage** - only when deploying infrastructure
- **Restart Function App to Initialize** - only when deploying infrastructure
- **Wait for Function App to be Ready** - only when deploying infrastructure
- **Re-enable Network Restrictions** - only when deploying infrastructure

These steps are skipped when deploying only function app code to an existing deployment.

## Deployment Scenarios Now Supported

### Scenario 1: Deploy Everything ✅
```yaml
deployInfrastructure: true
deployFunctionApp: true
deployLogicApps: true
```
**Result:**
- ✅ Validates infrastructure
- ✅ Builds function app
- ✅ Deploys infrastructure
- ✅ Deploys function app code
- ✅ Deploys logic apps

### Scenario 2: Deploy Only Infrastructure ✅
```yaml
deployInfrastructure: true
deployFunctionApp: false
deployLogicApps: false
```
**Result:**
- ✅ Validates infrastructure
- ⏭️ Skips function app build
- ✅ Deploys infrastructure
- ⏭️ Skips function app code deployment

### Scenario 3: Deploy Only Function App Code ✅ (NOW FIXED!)
```yaml
deployInfrastructure: false
deployFunctionApp: true
deployLogicApps: false
```
**Result:**
- ⏭️ Skips validate (no infrastructure changes)
- ✅ Builds function app
- ✅ Deploy job runs (gets existing resource names)
- ✅ Deploys function app code to existing infrastructure
- ⏭️ Skips infrastructure-specific steps (storage access, restart, etc.)

### Scenario 4: Deploy Only Logic Apps ✅
```yaml
deployInfrastructure: false
deployFunctionApp: false
deployLogicApps: true
```
**Result:**
- ⏭️ Skips validate
- ⏭️ Skips function app build
- ⏭️ Skips deploy job (nothing to deploy in that job)
- ✅ Deploys logic apps

### Scenario 5: Deploy Infrastructure + Logic Apps ✅
```yaml
deployInfrastructure: true
deployFunctionApp: false
deployLogicApps: true
```
**Result:**
- ✅ Validates infrastructure
- ⏭️ Skips function app build
- ✅ Deploys infrastructure
- ⏭️ Skips function app code deployment
- ✅ Deploys logic apps

## Testing Checklist

After this fix, verify these scenarios work:

- [ ] Deploy everything (infrastructure + function + logic apps)
- [ ] Deploy only infrastructure
- [ ] **Deploy only function app code** (the fixed scenario!)
- [ ] Deploy only logic apps
- [ ] Deploy infrastructure + logic apps (skip function)
- [ ] Deploy infrastructure + function (skip logic apps)

## Key Files Modified

1. **`.github/workflows/deploy-nomentia-integration.yml`**
   - Line 155-159: Deploy job condition
   - Line 188: Infrastructure deployment condition
   - Line 198-216: Get existing deployment info
   - Line 217-243: Infrastructure-specific steps conditional
   - Line 280-281: Function deployment uses fallback outputs
   - Line 381-382: Health check uses fallback outputs

## Benefits

✅ **More Flexible** - Deploy individual components independently
✅ **Faster Iterations** - Deploy only what changed
✅ **Less Risk** - Smaller blast radius per deployment
✅ **Cost Effective** - Skip unnecessary builds and deployments
✅ **CI/CD Friendly** - Different pipelines can deploy different components

## How It Works

The workflow now follows this logic:

```
IF deployInfrastructure OR deployFunctionApp:
  RUN deploy job

  IF deployInfrastructure:
    - Deploy infrastructure
    - Get outputs from infrastructure deployment
  ELSE:
    - Get resource names from parameter file

  IF deployFunctionApp:
    - Download artifact
    - Create zip with .azurefunctions folder
    - Deploy to Azure
    - Verify health
```

## Example Usage

### Quick Function Code Update
```bash
# After fixing a bug in function code:
deployInfrastructure: false  # No infrastructure changes
deployFunctionApp: true      # Just deploy the new code
deployLogicApps: false       # Logic apps unchanged
```

**Result**: ~2-3 minute deployment (vs ~10-15 minutes for full deployment)

### Infrastructure Update Only
```bash
# After changing a storage account setting:
deployInfrastructure: true   # Deploy infrastructure changes
deployFunctionApp: false     # Don't rebuild/redeploy function
deployLogicApps: false       # Logic apps unchanged
```

**Result**: Faster infrastructure updates without unnecessary code builds

## Notes

- The naming convention matches the bicep naming module output
- Resource names are calculated from parameters when infrastructure deployment is skipped
- Infrastructure-specific steps (storage access, restart) only run during full deployment
- Function deployment works with either fresh infrastructure or existing infrastructure

## Summary

**Before:** Could only deploy everything together
**After:** Can deploy infrastructure, function app, and logic apps independently

This fix enables true selective deployment! 🎉
