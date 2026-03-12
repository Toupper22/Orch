# AGENTS.md

## Purpose
This file provides quick context and guardrails for automated agents and contributors.

## Repository focus
- Infrastructure as Code for Azure integrations using Bicep templates.
- Integration application code under `src/` (C#/.NET) with solution file `Orch.sln`.

## Key references
- `README.md` for overview and architecture.
- `docs/TESTING.md` for validation and what-if guidance.
- `docs/PARAMETER-FILE-MANAGEMENT.md` for parameter file rules.
- `docs/SETUP.md` and `docs/QUICKSTART-NEW-INTEGRATION.md` for onboarding.
- `bicep/modules/README-standardIntegration.md` for the standard integration template.

## Project layout (high level)
- `bicep/common/`: common infrastructure templates and parameters.
- `bicep/modules/`: reusable modules; `standardIntegration.bicep` is the preferred entry.
- `bicep/integrations/`: integration-specific parameters and workflow types.
- `config/`: `settings.json` (global config) and `subscriptions.json` (environment mapping).
- `scripts/`: parameter generation and validation scripts.
- `src/`: .NET projects; `Orch.sln` at repo root.

## Parameter management rules
- Common infra parameters in `bicep/common/parameters.*.json` are generated from
  `config/settings.json` via `scripts/generate-common-params.sh` and are safe to regenerate.
- Integration parameters in `bicep/integrations/<name>/parameters.*.json` are manual after
  initial creation. Use `scripts/create-integration-params.sh` once per integration.
- Do not use `scripts/generate-integration-params.sh` for customized integrations
  (deprecated for general use).
- When `config/settings.json` changes, regenerate common parameters and manually update
  integration parameters as needed.
- Never commit secrets in parameter files; use Key Vault references instead.

## Testing and validation
- Quick syntax validation: `./scripts/validate-bicep.sh`
- Full validation and what-if flow: `./scripts/test-deployment.sh`
  (requires Azure CLI login and access to subscriptions in `config/subscriptions.json`).
- There are no dedicated test projects under `src/` currently; for .NET changes, run
  `dotnet build Orch.sln` and any project-specific tests if added later.

## Standards
- Prefer `bicep/modules/standardIntegration.bicep` for new integrations.
- Keep integration parameter files aligned across environments unless a difference is
  intentional and documented.
- Follow existing formatting and naming conventions; avoid large unreviewed parameter changes.
