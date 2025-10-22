# Troubleshooting GitHub Actions Azure Login

## Error: "No subscriptions found for ***"

This error occurs when the service principal in your `AZURE_CREDENTIALS` secret doesn't have access to any Azure subscriptions.

### Quick Diagnosis

Run these commands to diagnose the issue:

```bash
# 1. Check if your service principal exists
az ad sp list --display-name "github-actions-orch" --output table

# 2. Get the App ID (Client ID)
APP_ID=$(az ad sp list --display-name "github-actions-orch" --query "[0].appId" -o tsv)
echo "App ID: $APP_ID"

# 3. Check what role assignments this service principal has
az role assignment list --assignee $APP_ID --all --output table

# If the table is empty, that's your problem! The SP has no permissions.
```

### Solution 1: Grant Service Principal Access to Subscription

The most common cause is that the service principal was created but never assigned permissions.

**Step 1: Get your subscription ID**

```bash
# Login with your user account (not the service principal)
az login

# List your subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "your-subscription-id"

# Verify
az account show
```

**Step 2: Grant Contributor role to the service principal**

```bash
# Get the service principal App ID
APP_ID=$(az ad sp list --display-name "github-actions-orch" --query "[0].appId" -o tsv)

# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Grant Contributor role
az role assignment create \
  --assignee $APP_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Verify the assignment
az role assignment list --assignee $APP_ID --output table
```

**Step 3: If you have multiple subscriptions (dev, test, prod)**

```bash
APP_ID=$(az ad sp list --display-name "github-actions-orch" --query "[0].appId" -o tsv)

# Grant access to each subscription
az role assignment create --assignee $APP_ID --role "Contributor" \
  --scope "/subscriptions/your-dev-subscription-id"

az role assignment create --assignee $APP_ID --role "Contributor" \
  --scope "/subscriptions/your-test-subscription-id"

az role assignment create --assignee $APP_ID --role "Contributor" \
  --scope "/subscriptions/your-prod-subscription-id"
```

### Solution 2: Recreate Service Principal with Proper Permissions

If the above doesn't work, recreate the service principal:

**Step 1: Delete the old service principal (optional)**

```bash
# Find the App ID
APP_ID=$(az ad sp list --display-name "github-actions-orch" --query "[0].appId" -o tsv)

# Delete it
az ad sp delete --id $APP_ID
```

**Step 2: Create new service principal with access**

```bash
# Login and set subscription
az login
az account set --subscription "your-subscription-id"

# Create service principal with Contributor role on subscription
az ad sp create-for-rbac \
  --name "github-actions-orch" \
  --role "Contributor" \
  --scopes "/subscriptions/$(az account show --query id -o tsv)" \
  --sdk-auth

# IMPORTANT: Copy the entire JSON output!
```

**Expected output:**
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
  "tenantId": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Solution 3: Verify AZURE_CREDENTIALS Secret Format

**Step 1: Check the secret in GitHub**

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click on `AZURE_CREDENTIALS` to verify it exists

**Step 2: Verify the JSON format**

The secret should be the EXACT JSON output from `az ad sp create-for-rbac --sdk-auth`. Example:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
  "tenantId": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

**Common mistakes:**
- ❌ Missing fields
- ❌ Extra spaces or line breaks
- ❌ Missing quotes around values
- ❌ Wrong subscription ID in the JSON vs. `config/subscriptions.json`

**Step 3: Update the secret if needed**

1. Go to Settings → Secrets and variables → Actions
2. Click `AZURE_CREDENTIALS`
3. Click "Update secret"
4. Paste the correct JSON
5. Click "Update secret"

### Solution 4: Verify Subscription ID Match

The `subscriptionId` in `AZURE_CREDENTIALS` should match what's in `config/subscriptions.json`.

**Check your config:**

```bash
# View your subscription configuration
cat config/subscriptions.json

# Example:
{
  "subscriptions": {
    "dev": {
      "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "subscriptionName": "Development Subscription"
    }
  }
}
```

**Verify match:**
1. The `subscriptionId` in `AZURE_CREDENTIALS` secret
2. Should be present in `config/subscriptions.json` for at least one environment
3. Or the service principal should have access to ALL subscriptions listed

### Solution 5: Use Environment-Specific Secrets (Alternative)

Instead of one `AZURE_CREDENTIALS` for all environments, you can use environment-specific secrets.

**Step 1: Create service principal for each environment**

```bash
# Dev environment
az account set --subscription "dev-subscription-id"
az ad sp create-for-rbac \
  --name "github-actions-orch-dev" \
  --role "Contributor" \
  --scopes "/subscriptions/dev-subscription-id" \
  --sdk-auth

# Test environment
az account set --subscription "test-subscription-id"
az ad sp create-for-rbac \
  --name "github-actions-orch-test" \
  --role "Contributor" \
  --scopes "/subscriptions/test-subscription-id" \
  --sdk-auth
```

**Step 2: Configure in GitHub**

1. Settings → Environments → dev
2. Add secret `AZURE_CREDENTIALS` with dev service principal JSON
3. Repeat for test, uat, prod environments

This gives you fine-grained control and better security.

## Testing the Fix

After applying any of the above solutions, test the authentication:

### Test 1: Manual Azure CLI Test

```bash
# Extract values from your AZURE_CREDENTIALS JSON
CLIENT_ID="xxx"
CLIENT_SECRET="xxx"
TENANT_ID="xxx"
SUBSCRIPTION_ID="xxx"

# Login using service principal
az login --service-principal \
  --username $CLIENT_ID \
  --password $CLIENT_SECRET \
  --tenant $TENANT_ID

# Check subscriptions
az account list --output table

# If you see subscriptions listed, authentication works!
```

### Test 2: Trigger GitHub Actions Workflow

1. Go to Actions tab
2. Select "Deploy Common Infrastructure"
3. Click "Run workflow"
4. Select environment: dev
5. Check "What-If" (to avoid actual deployment)
6. Run

If it passes the "Azure Login" step, you're good!

## Prevention Checklist

For future service principal setups:

- [ ] Create service principal with `--role Contributor` and `--scopes /subscriptions/...`
- [ ] Verify role assignment with `az role assignment list --assignee $APP_ID`
- [ ] Copy entire JSON output from `--sdk-auth` command
- [ ] Paste JSON exactly into GitHub secret (no modifications)
- [ ] Verify subscription ID in secret matches `config/subscriptions.json`
- [ ] Test authentication manually before using in GitHub Actions
- [ ] Document which service principal is used for which environments

## Common Error Messages

### "AADSTS7000215: Invalid client secret provided"
**Cause:** Wrong client secret in AZURE_CREDENTIALS
**Fix:** Recreate service principal and update secret

### "AADSTS700016: Application not found"
**Cause:** Service principal was deleted or clientId is wrong
**Fix:** Verify service principal exists or recreate

### "AuthorizationFailed: The client does not have permission"
**Cause:** Service principal has subscription access but not enough permissions
**Fix:** Grant "Contributor" role (not just "Reader")

### "Subscription 'xxx' not found"
**Cause:** Subscription ID in config/subscriptions.json doesn't match reality
**Fix:** Update config/subscriptions.json with correct subscription IDs

## Need More Help?

1. **Check Azure Portal:**
   - Azure Active Directory → App registrations → All applications
   - Search for "github-actions-orch"
   - Check "API permissions" and "Certificates & secrets"

2. **Check Service Principal in Azure:**
   - Subscriptions → Your Subscription → Access control (IAM)
   - Check role assignments
   - Search for your service principal

3. **Enable Debug Logging in GitHub Actions:**
   - Repository Settings → Secrets and variables → Actions
   - Add secret: `ACTIONS_STEP_DEBUG` = `true`
   - Re-run workflow to see detailed logs

4. **Contact Support:**
   - Check Azure subscription status
   - Verify you have permission to create service principals
   - Verify you have "Owner" or "User Access Administrator" role on subscription

---

**Last Updated:** 2025-10-22
