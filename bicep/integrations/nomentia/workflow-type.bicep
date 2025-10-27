// Single Workflow Type Deployment
// Deploys 3 Consumption Logic Apps for one workflow type (starter, process, common)

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

@description('Workflow type name (e.g., d365fo-nomentia-artransactions)')
param workflowType string

@description('Common tags')
param tags object = {}

// Workflow definitions
@description('Starter workflow definition')
param starterWorkflowDefinition object

@description('Process workflow definition')
param processWorkflowDefinition object

@description('Common workflow definition')
param commonWorkflowDefinition object

@description('Enable IP-based access restrictions for run history (contents). Triggers will use "Only other Logic Apps" mode.')
param enableContentIpRestrictions bool = true

@description('Array of allowed caller IP addresses (CIDR notation) for viewing run history - configured centrally in config/settings.json')
param allowedCallerIpAddresses array

// ============================================================================
// Variables
// ============================================================================

var resourceGroupName = '${prefix}-${environment}-${integrationName}-rg'
var commonResourceGroupName = '${prefix}-${environment}-common-rg'

var commonTags = union(tags, {
  Environment: environment
  Integration: integrationName
  WorkflowType: workflowType
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

// Logic App names follow pattern: {prefix}-{env}-{integration}-{workflowType}-{stage}-logic
var starterLogicAppName = '${prefix}-${environment}-${integrationName}-${workflowType}-starter-logic'
var processLogicAppName = '${prefix}-${environment}-${integrationName}-${workflowType}-process-logic'
var commonLogicAppName = '${prefix}-${environment}-${integrationName}-${workflowType}-common-logic'

// ============================================================================
// Logic Apps
// ============================================================================

// Starter Logic App
module starterLogicApp '../../modules/logicAppConsumption.bicep' = {
  name: 'starter-${workflowType}'
  scope: integrationResourceGroup
  params: {
    logicAppName: starterLogicAppName
    location: location
    tags: union(commonTags, { Stage: 'Starter' })
    workflowDefinition: starterWorkflowDefinition
    managedIdentityId: commonManagedIdentity.id
    state: 'Enabled'
    enableContentIpRestrictions: enableContentIpRestrictions
    allowedCallerIpAddresses: allowedCallerIpAddresses
  }
}

// Process Logic App
module processLogicApp '../../modules/logicAppConsumption.bicep' = {
  name: 'process-${workflowType}'
  scope: integrationResourceGroup
  params: {
    logicAppName: processLogicAppName
    location: location
    tags: union(commonTags, { Stage: 'Process' })
    workflowDefinition: processWorkflowDefinition
    managedIdentityId: commonManagedIdentity.id
    state: 'Enabled'
    enableContentIpRestrictions: enableContentIpRestrictions
    allowedCallerIpAddresses: allowedCallerIpAddresses
  }
}

// Common Logic App
module commonLogicApp '../../modules/logicAppConsumption.bicep' = {
  name: 'common-${workflowType}'
  scope: integrationResourceGroup
  params: {
    logicAppName: commonLogicAppName
    location: location
    tags: union(commonTags, { Stage: 'Common' })
    workflowDefinition: commonWorkflowDefinition
    managedIdentityId: commonManagedIdentity.id
    state: 'Enabled'
    enableContentIpRestrictions: enableContentIpRestrictions
    allowedCallerIpAddresses: allowedCallerIpAddresses
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Starter Logic App name')
output starterLogicAppName string = starterLogicApp.outputs.name

@description('Starter Logic App ID')
output starterLogicAppId string = starterLogicApp.outputs.id

@description('Process Logic App name')
output processLogicAppName string = processLogicApp.outputs.name

@description('Process Logic App ID')
output processLogicAppId string = processLogicApp.outputs.id

@description('Common Logic App name')
output commonLogicAppName string = commonLogicApp.outputs.name

@description('Common Logic App ID')
output commonLogicAppId string = commonLogicApp.outputs.id
