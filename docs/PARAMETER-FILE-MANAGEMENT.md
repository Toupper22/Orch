# Parameter File Management Guide

Understanding when and how to use parameter generation scripts vs. manual editing.

## Overview

The project has two types of parameter files with different management approaches:

| Type | Location | Management Approach | Script to Use |
|------|----------|-------------------|---------------|
| **Common Infrastructure** | `bicep/common/parameters.*.json` | Generated from `config/settings.json` | ✅ `generate-common-params.sh` |
| **Integration-Specific** | `bicep/integrations/{name}/parameters.*.json` | Manual maintenance | ⚠️ `create-integration-params.sh` (once only) |

## Common Infrastructure Parameters

### ✅ Safe to Regenerate

Common infrastructure parameters are derived from global settings and **can be safely regenerated** anytime.

**When to regenerate:**
- Changed global settings in `config/settings.json`
- Adding a new environment
- Want to reset to defaults

**How to regenerate:**

```bash
# Regenerate all environments
./scripts/generate-common-params.sh
# Select: 5 (all)

# Or regenerate specific environment
./scripts/generate-common-params.sh
# Select: 1 (dev)
```

**What happens:**
- Files in `bicep/common/parameters.*.json` are overwritten
- Values pulled from `config/settings.json`
- No custom changes needed here

### Configuration Flow

```
config/settings.json
       ↓
generate-common-params.sh
       ↓
bicep/common/parameters.{env}.json  ← Safe to regenerate
```

## Integration-Specific Parameters

### ⚠️ Manual Maintenance Required

Integration parameter files contain **integration-specific customizations** and should be manually maintained after initial creation.

**When to create (first time only):**
- Creating a new integration
- Need parameter file templates

**How to create initially:**

```bash
# Use the safe creation script
./scripts/create-integration-params.sh

# Prompts for:
# - Integration name
# - Which environments to create
# - Warns before overwriting existing files
```

**What happens:**
- Creates `bicep/integrations/{name}/parameters.*.json`
- Pulls base values from `config/settings.json`
- Sets integration name and basic defaults
- **Creates backup if file exists**

### After Initial Creation: Manual Editing Only

Once created, **NEVER regenerate** these files. Edit manually instead.

**Example customizations:**

```json
{
  "parameters": {
    "serviceBusSku": {
      "value": "Premium"  // Upgraded from Standard for high throughput
    },
    "customQueueConfig": {
      "value": {
        "maxDeliveryCount": 20,  // Custom retry logic
        "lockDuration": "PT10M"   // Extended lock time
      }
    }
  }
}
```

### Configuration Flow

```
Initial Creation:
config/settings.json + create-integration-params.sh
       ↓
bicep/integrations/{name}/parameters.{env}.json
       ↓
Developer manually edits with custom values  ← Do NOT regenerate!
       ↓
Git commit (tracked in version control)
```

## Script Usage Quick Reference

### `generate-common-params.sh`

```bash
./scripts/generate-common-params.sh
```

**Purpose:** Generate/regenerate common infrastructure parameters
**Safe to run:** ✅ YES, anytime
**Overwrites:** Common infrastructure files only
**Use when:**
- Initial project setup
- Changed global settings
- Adding new environments

### `create-integration-params.sh` (NEW)

```bash
./scripts/create-integration-params.sh
```

**Purpose:** Create initial parameter files for a new integration
**Safe to run:** ⚠️ ONLY ONCE per integration
**Overwrites:** Will warn and create backups
**Use when:**
- Creating a new integration for the first time
- Need template parameter files

**DON'T use after:**
- You've made custom changes
- Files already exist and are customized

### `generate-integration-params.sh` (OLD - DEPRECATED)

**Status:** ❌ Deprecated for custom integrations
**Purpose:** Originally for sample integration only
**Safe to run:** ⚠️ NO, overwrites without warning
**Recommendation:** Use `create-integration-params.sh` instead

## Common Scenarios

### Scenario 1: Starting a New Project

```bash
# 1. Update global settings
vim config/settings.json

# 2. Generate common infrastructure parameters
./scripts/generate-common-params.sh

# 3. Deploy common infrastructure
# (via GitHub Actions or Azure CLI)
```

### Scenario 2: Adding First Integration

```bash
# 1. Copy sample integration template
cp -r bicep/integrations/sample-integration bicep/integrations/my-integration

# 2. Create parameter files
./scripts/create-integration-params.sh
# Enter: my-integration
# Select: 5 (all environments)

# 3. Manually edit parameter files with custom values
vim bicep/integrations/my-integration/parameters.dev.json

# 4. Commit to Git
git add bicep/integrations/my-integration/
git commit -m "Add my-integration with custom Service Bus Premium tier"
```

### Scenario 3: Updating Integration Configuration

```bash
# 1. Edit parameter file directly
vim bicep/integrations/my-integration/parameters.dev.json

# 2. Change what you need (e.g., Service Bus SKU)

# 3. Commit changes
git add bicep/integrations/my-integration/parameters.dev.json
git commit -m "Upgrade Service Bus to Premium for my-integration dev"

# 4. Deploy
# (via GitHub Actions or Azure CLI)
```

### Scenario 4: Changed Global Project Settings

```bash
# 1. Update global settings
vim config/settings.json
# Changed prefix from "contoso" to "fabrikam"

# 2. Regenerate ONLY common infrastructure parameters
./scripts/generate-common-params.sh
# Select: 5 (all)

# 3. Manually update integration parameter files
# (because they won't auto-update)
vim bicep/integrations/my-integration/parameters.dev.json
# Update "prefix" to "fabrikam"

# 4. Commit all changes
git add config/settings.json bicep/
git commit -m "Update project prefix to fabrikam"
```

### Scenario 5: Accidentally Overwrote Integration Parameters

```bash
# If you used create-integration-params.sh, a backup was created

# Find the backup
ls -la bicep/integrations/my-integration/
# Look for: parameters.dev.json.backup.20251022-143022

# Restore from backup
cp bicep/integrations/my-integration/parameters.dev.json.backup.* \
   bicep/integrations/my-integration/parameters.dev.json

# Or restore from Git
git checkout bicep/integrations/my-integration/parameters.dev.json
```

## Best Practices

### ✅ DO

- **Common params:** Regenerate whenever global settings change
- **Integration params:** Create once, then manual edit only
- **Always:** Commit parameter files to Git
- **Always:** Use meaningful commit messages for parameter changes
- **Always:** Review parameter diffs before committing
- **Before deploy:** Use what-if mode to preview changes

### ❌ DON'T

- **Don't:** Regenerate integration parameters after customization
- **Don't:** Commit secrets to parameter files (use Key Vault references)
- **Don't:** Edit common parameters manually (use global settings instead)
- **Don't:** Copy parameter files between integrations without reviewing values

## Troubleshooting

### "I regenerated integration params and lost my customizations"

**Solution:**
1. Check Git history: `git log bicep/integrations/{name}/parameters.*.json`
2. Restore from Git: `git checkout HEAD~1 -- bicep/integrations/{name}/parameters.dev.json`
3. Or use backup file if using `create-integration-params.sh`

### "My integration still uses old prefix after updating global settings"

**Solution:**
Integration parameter files don't auto-update. You need to manually edit them or:
1. Delete integration parameter files
2. Run `./scripts/create-integration-params.sh`
3. Re-apply your customizations

### "Parameters are out of sync across environments"

**Solution:**
```bash
# Compare files
diff bicep/integrations/my-integration/parameters.dev.json \
     bicep/integrations/my-integration/parameters.prod.json

# Identify environment-specific values vs. shared config
# Update manually to keep in sync
```

## Summary

| Action | Common Infrastructure | Integration-Specific |
|--------|----------------------|---------------------|
| Initial creation | ✅ Generate script | ✅ Create script (once) |
| After customization | ✅ Regenerate anytime | ❌ Manual edit only |
| Update global settings | ✅ Regenerate | ⚠️ Manual update |
| Add new environment | ✅ Generate | ✅ Create or copy+edit |
| Version control | ✅ Git commit | ✅ Git commit |
| Backup strategy | Not needed (regenerable) | ✅ Script creates backups |

---

**Key Takeaway:** Common infrastructure parameters are **configuration-driven** and regenerable. Integration parameters are **customization-driven** and manually maintained.

**Last Updated:** 2025-10-22
