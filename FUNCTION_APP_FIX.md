# Function App Deployment Fix - Missing .azurefunctions Folder

## Problem

Functions were not appearing in the Azure Portal after deployment, even though:
- Deployment succeeded
- Runtime was showing
- Build completed successfully

### Error Message

```
"Could not find the .azurefunctions folder in the deployed artifacts of a .NET isolated function app.
Make sure that your deployment package includes the .azurefunctions folder at the root of the package."
```

## Root Cause

The `.azurefunctions` folder was being **excluded from the deployment zip file** because:

1. **Hidden files excluded from zip**: The zip command `zip -r function-app.zip .` does not include dotfiles (files/folders starting with `.`) by default
2. The `.azurefunctions` folder starts with a dot, making it a hidden file
3. This folder is **required** for .NET Isolated worker functions to be discovered by the Azure Functions runtime

## What is the .azurefunctions Folder?

The `.azurefunctions` folder is automatically generated during `dotnet publish` for .NET Isolated worker functions and contains:

- `function.deps.json` - Dependency metadata
- `Microsoft.Azure.Functions.Worker.Extensions.dll` - Worker extensions
- Other required metadata files

**This folder is critical** - without it, Azure Functions cannot discover your functions even though the deployment succeeds.

## Solution

### 1. Fixed the Zip Command ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:253-257`

**Before:**
```bash
cd function-app-package
zip -r ../function-app.zip .
cd ..
```

**After:**
```bash
cd function-app-package
# Include hidden files (.azurefunctions folder) in zip
shopt -s dotglob
zip -r ../function-app.zip *
shopt -u dotglob
cd ..
```

**Explanation:**
- `shopt -s dotglob` - Enables globbing of dotfiles in bash
- `zip -r ../function-app.zip *` - Now includes all files, including hidden ones
- `shopt -u dotglob` - Disables dotglob after use (clean up)

### 2. Added Verification After Build ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:73-82`

```yaml
- name: Verify .azurefunctions Folder Exists
  run: |
    if [ -d "src/Efima.IL.Nomentia/publish/.azurefunctions" ]; then
      echo "✅ .azurefunctions folder found in publish output"
      ls -la src/Efima.IL.Nomentia/publish/.azurefunctions/
    else
      echo "❌ ERROR: .azurefunctions folder NOT found in publish output"
      echo "This will cause deployment to fail. Check .csproj configuration."
      exit 1
    fi
```

**Benefit**: Fails early if .azurefunctions folder is missing, with a clear error message

### 3. Added Verification After Zip ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:259-260`

```bash
echo "Verifying .azurefunctions folder is in the zip..."
unzip -l ../function-app.zip | grep ".azurefunctions" || echo "WARNING: .azurefunctions folder not found in zip!"
```

**Benefit**: Confirms the folder made it into the deployment package

### 4. Ensured Artifact Upload Includes Hidden Files ✅

**File**: `.github/workflows/deploy-nomentia-integration.yml:89`

```yaml
- name: Upload Function App Package
  uses: actions/upload-artifact@v4
  with:
    name: function-app-package
    path: src/Efima.IL.Nomentia/publish
    include-hidden-files: true  # ← Added this
```

## Testing the Fix

After deploying with these changes, you should see:

### In Build Logs:
```
✅ .azurefunctions folder found in publish output
drwxr-xr-x    8 runner  docker      256 Oct 23 20:15 .
drwxr-xr-x  133 runner  docker     4256 Oct 23 20:15 ..
-rw-r--r--    1 runner  docker     4608 Oct 23 20:15 Microsoft.Azure.Functions.Worker.Extensions.dll
...
```

### In Deployment Logs:
```
Verifying .azurefunctions folder is in the zip...
    102275  10-23-2024 20:15   .azurefunctions/function.deps.json
      4608  10-23-2024 20:15   .azurefunctions/Microsoft.Azure.Functions.Worker.Extensions.dll
...
```

### In Azure Portal:

After deployment, navigate to:
- **Azure Portal** → **Your Function App** → **Functions**

You should now see your functions:
- `BankStatementTransform`
- `D365ArTransactionsTransform`

## Previous Fix (Also Required)

This fix complements the earlier fix where we removed the `extensionBundle` from `host.json`:

**File**: `src/Efima.IL.Nomentia/host.json`

**Removed:**
```json
"extensionBundle": {
  "id": "Microsoft.Azure.Functions.ExtensionBundle",
  "version": "[4.*, 5.0.0)"
}
```

**Why**: Extension bundles are only for scripting languages, not .NET Isolated worker functions.

## Common Gotchas

### 1. Dotfiles in Zip Archives

**Problem**: Standard `zip` command excludes dotfiles when using `.` pattern

**Solutions**:
- Use `shopt -s dotglob` before zipping
- Use explicit file list
- Use `zip -r archive.zip * .[^.]*` (includes dotfiles)

### 2. GitHub Actions Artifacts

**Problem**: `upload-artifact@v4` may exclude hidden files by default

**Solution**: Add `include-hidden-files: true` parameter

### 3. .NET Isolated vs In-Process

**.NET Isolated** (our case):
- ✅ Requires `.azurefunctions` folder
- ✅ Uses `Microsoft.Azure.Functions.Worker` packages
- ✅ No extension bundles

**.NET In-Process**:
- ❌ Does not use `.azurefunctions` folder
- Uses `Microsoft.NET.Sdk.Functions` SDK
- Different deployment structure

## Verification Checklist

After deployment, verify:

- [ ] Build logs show `.azurefunctions` folder exists
- [ ] Zip verification shows `.azurefunctions` in package
- [ ] Deployment succeeds without errors
- [ ] Functions appear in Azure Portal
- [ ] Function App logs don't show "MissingAzureFunctionsFolder" warning
- [ ] Test function execution works

## Related Files

- `.github/workflows/deploy-nomentia-integration.yml` - Deployment workflow
- `src/Efima.IL.Nomentia/host.json` - Function app configuration
- `src/Efima.IL.Nomentia/Efima.IL.Nomentia.csproj` - Project file

## Additional Resources

- [Azure Functions deployment technologies](https://aka.ms/functions-deployment-technologies)
- [.NET Isolated worker guide](https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide)
- [Function app deployment](https://learn.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies)

## Summary

The issue was caused by the deployment zip excluding the `.azurefunctions` folder due to it being a hidden file (starts with `.`). The fix ensures:

1. ✅ Dotfiles are included in zip archive
2. ✅ Dotfiles are included in artifact upload
3. ✅ Early verification catches missing folder
4. ✅ Post-zip verification confirms folder is packaged

Your functions should now be visible and executable in the Azure Portal after the next deployment!
