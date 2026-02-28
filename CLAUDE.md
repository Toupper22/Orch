# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Azure integration template repository for building Dynamics 365 Finance & Operations integrations. Two main technology layers:
- **Bicep IaC** — Modular Azure infrastructure templates
- **C# (.NET 8)** — Azure Functions (isolated worker model) for data transformation

## Build & Validate Commands

```bash
# Bicep
./scripts/validate-bicep.sh                    # Quick syntax validation
./scripts/test-deployment.sh                   # Full what-if deployment test
az bicep build --file bicep/common/main.bicep  # Validate single template

# C#
dotnet build src/Efima.IL.sln                  # Build entire solution
dotnet build src/Efima.IL/Efima.IL.csproj      # Core library only
dotnet build src/Efima.IL.Nomentia/Efima.IL.Nomentia.csproj  # Nomentia function app

# Parameter generation (from config/settings.json)
./scripts/generate-common-params.sh
./scripts/generate-integration-params.sh
```

## Architecture

**Two-layer infrastructure design:**

1. **Common Infrastructure** (`bicep/common/main.bicep`) — Shared resources: VNet, NAT Gateway, Key Vault, Storage, App Service Plan, Managed Identity, Application Insights, Service Bus
2. **Per-Integration Resources** (`bicep/integrations/<name>/`) — Isolated per integration: Key Vault, Storage Accounts, Logic Apps (Consumption), Function Apps, Service Bus, API Connections

**Preferred approach:** Use `bicep/modules/standardIntegration.bicep` (unified parameterized template) for new integrations. The sample-integration uses a legacy custom main.bicep approach.

**Configuration hierarchy:**
```
config/settings.json  →  generate scripts  →  bicep/**/parameters.{env}.json  →  deployment
```
`config/settings.json` is the single source of truth. Don't edit parameter files directly; regenerate them.

## C# Patterns

- **Base classes:** `FunctionTriggerBase<TReq, TRes>` and `TransformTriggerBase<TReq, TRes>` handle HTTP scaffolding, error handling, JSON serialization
- **Service layer:** `IDataTransformService<TReq, TRes>` interface with concrete implementations per integration
- **Token auth:** `ITokenProvider` → `BearerTokenAuthHandler` injects OAuth tokens into HTTP clients
- **DI setup:** Each function app has `Program.cs` configuring `IServiceCollection`
- **Core library:** `src/Efima.IL/` contains shared utilities, extensions, models, and base classes used by all integrations

## Bicep Conventions

- **Naming module:** `bicep/modules/naming.bicep` enforces `{prefix}-{env}-{location}-{resourceType}` naming
- **Linting:** `bicepconfig.json` at repo root defines analyzer rules (no unused params/vars, secure defaults, no hardcoded values)
- **Security:** RBAC over access policies, managed identities (no credentials), Key Vault network ACLs default deny
- **Environment tiers:** dev/test (B1, Standard_LRS) → prod (S2, Standard_GRS, Premium KV)
- **Tags:** Environment, Customer, Project, ManagedBy=Bicep, CostCenter on all resources

## CI/CD (GitHub Actions)

Workflows in `.github/workflows/` follow a three-stage pattern: Validate → Preview (what-if) → Deploy. Each environment (dev, test, uat, prod) uses separate GitHub environment secrets. Subscription IDs are mapped in `config/subscriptions.json`.

## Key Directories

- `bicep/modules/` — 24 reusable Bicep modules (one resource type each)
- `src/Efima.IL/` — Core shared C# library (base classes, utilities, extensions, models)
- `src/Efima.IL.Nomentia/` — Production Nomentia integration function app
- `config/` — Global settings and subscription mappings
- `scripts/` — Deployment validation and parameter generation scripts
- `docs/` — Setup, testing, configuration, troubleshooting guides
