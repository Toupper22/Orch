// Single Logic App Workflow Deployment
// Generic reusable template for deploying a single Consumption Logic App

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================

@description('Customer/project prefix for resource naming')
param prefix string

@description('Environment name (dev, test, uat, prod)')
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
])
param environment string

@description('Azure region for resources')
param location string = deployment().location

@description('Azure region short code')
param locationShort string

@description('Integration name')
param integrationName string = 'nomentia'

@description('Workflow name (e.g., d365fo-nomentia-artransactions)')
param workflowName string

@description('Common tags')
param tags object = {}

@description('Workflow definition JSON')
param workflowDefinition object

@description('Workflow parameters (optional)')
param workflowParameters object = {}

@description('API connections (optional)')
param connections object = {}

@description('Enable or disable the workflow')
param state string = 'Enabled'

// ============================================================================
// Variables
// ============================================================================

var resourceGroupName = '${prefix}-${environment}-${integrationName}-rg'
var commonResourceGroupName = '${prefix}-${environment}-common-rg'

var commonTags = union(tags, {
  Environment: environment
  Integration: integrationName
  Workflow: workflowName
  ManagedBy: 'Bicep'
})

// ============================================================================
// Reference Existing Resources
// ============================================================================

// Reference integration resource group
resource integrationResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: resourceGroupName
  scope: subscription()
}

// Reference common resource group
resource commonResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: commonResourceGroupName
  scope: subscription()
}

// Reference common Managed Identity
resource commonManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: replace('${prefix}-${environment}-${locationShort}-id', '-', '')
  scope: commonResourceGroup
}

// ============================================================================
// Naming
// ============================================================================

var logicAppName = '${prefix}-${environment}-${integrationName}-${workflowName}-logic'

// ============================================================================
// Logic App
// ============================================================================

module logicApp '../../modules/logicAppConsumption.bicep' = {
  name: 'logicApp-${workflowName}'
  scope: integrationResourceGroup
  params: {
    logicAppName: logicAppName
    location: location
    tags: commonTags
    workflowDefinition: workflowDefinition
    workflowParameters: workflowParameters
    connections: connections
    managedIdentityId: commonManagedIdentity.id
    state: state
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Logic App name')
output logicAppName string = logicApp.outputs.name

@description('Logic App ID')
output logicAppId string = logicApp.outputs.id

@description('Logic App callback URL (if has manual trigger)')
output callbackUrl string = logicApp.outputs.callbackUrl
