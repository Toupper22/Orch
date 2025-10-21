// Sample Integration - Main Template
// Demonstrates end-to-end integration pattern using common infrastructure
// Flow: Service Bus → Logic App → Function App → Storage Account

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
param integrationName string = 'sample'

@description('Common tags')
param tags object = {}

// Service Bus parameters
@description('Service Bus SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string = 'Standard'

// ============================================================================
// Variables
// ============================================================================

var resourceGroupName = '${prefix}-${environment}-${integrationName}-rg'

// Calculate common infrastructure resource names based on naming convention
var commonResourceGroupName = '${prefix}-${environment}-common-rg'
var commonStorageAccountName = toLower(replace('${prefix}-${environment}-${locationShort}-st', '-', ''))
var commonVNetName = '${prefix}-${environment}-${locationShort}-vnet'

var commonTags = union(tags, {
  Environment: environment
  Integration: integrationName
  ManagedBy: 'Bicep'
})

// ============================================================================
// Reference Common Infrastructure (Existing Resources)
// ============================================================================

// Reference common resource group
resource commonResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: commonResourceGroupName
  scope: subscription()
}

// Reference common App Service Plan
resource commonAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: '${prefix}-${environment}-${locationShort}-plan'
  scope: commonResourceGroup
}

// Reference common Managed Identity
resource commonManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: replace('${prefix}-${environment}-${locationShort}-id', '-', '')
  scope: commonResourceGroup
}

// Reference common VNet
resource commonVNet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: commonVNetName
  scope: commonResourceGroup
}

// Reference integration subnet (first subnet in common VNet)
resource integrationSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'integration-subnet'
  parent: commonVNet
}

// IDs for passing to modules
var commonAppServicePlanId = commonAppServicePlan.id
var commonManagedIdentityId = commonManagedIdentity.id
var integrationSubnetId = integrationSubnet.id

// ============================================================================
// Resource Group
// ============================================================================

resource integrationResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

// ============================================================================
// Naming Modules
// ============================================================================

module serviceBusNaming '../../modules/naming.bicep' = {
  name: 'serviceBusNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'sb'
  }
}

module functionAppNaming '../../modules/naming.bicep' = {
  name: 'functionAppNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'func'
  }
}

module logicAppNaming '../../modules/naming.bicep' = {
  name: 'logicAppNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'logic'
  }
}

module storageAccountNaming '../../modules/naming.bicep' = {
  name: 'storageAccountNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'st'
  }
}

// ============================================================================
// Integration Storage Account
// ============================================================================

module integrationStorage '../../modules/storageAccount.bicep' = {
  name: 'integrationStorage'
  scope: integrationResourceGroup
  params: {
    storageAccountName: toLower(replace(storageAccountNaming.outputs.name, '-', ''))
    location: location
    tags: commonTags
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    containers: [
      {
        name: 'input-messages'
        publicAccess: 'None'
      }
      {
        name: 'transformed-messages'
        publicAccess: 'None'
      }
      {
        name: 'errors'
        publicAccess: 'None'
      }
    ]
  }
}

// ============================================================================
// Service Bus
// ============================================================================

module serviceBus '../../modules/serviceBus.bicep' = {
  name: 'serviceBus'
  scope: integrationResourceGroup
  params: {
    serviceBusName: serviceBusNaming.outputs.name
    location: location
    tags: commonTags
    skuName: serviceBusSku
    queues: [
      {
        name: 'incoming-messages'
        maxDeliveryCount: 10
        lockDuration: 'PT5M'
        defaultMessageTimeToLive: 'P7D'
      }
    ]
  }
}

// ============================================================================
// Function App (Message Transformer)
// ============================================================================

module functionApp '../../modules/functionApp.bicep' = {
  name: 'functionApp'
  scope: integrationResourceGroup
  params: {
    functionAppName: functionAppNaming.outputs.name
    location: location
    tags: commonTags
    appServicePlanId: commonAppServicePlanId
    storageAccountName: commonStorageAccountName
    managedIdentityId: commonManagedIdentityId
    vnetIntegrationSubnetId: integrationSubnetId
    enableVNetIntegration: true
    runtime: 'dotnet-isolated'
    runtimeVersion: '8.0'
    appSettings: [
      {
        name: 'ServiceBusConnection__fullyQualifiedNamespace'
        value: '${serviceBus.outputs.name}.servicebus.windows.net'
      }
      {
        name: 'IntegrationStorage__accountName'
        value: integrationStorage.outputs.name
      }
    ]
  }
}

// ============================================================================
// Logic App (Orchestrator)
// ============================================================================

module logicApp '../../modules/logicApp.bicep' = {
  name: 'logicApp'
  scope: integrationResourceGroup
  params: {
    logicAppName: logicAppNaming.outputs.name
    location: location
    tags: commonTags
    appServicePlanId: commonAppServicePlanId
    storageAccountName: commonStorageAccountName
    managedIdentityId: commonManagedIdentityId
    vnetIntegrationSubnetId: integrationSubnetId
    enableVNetIntegration: true
    appSettings: [
      {
        name: 'ServiceBusConnection__fullyQualifiedNamespace'
        value: '${serviceBus.outputs.name}.servicebus.windows.net'
      }
      {
        name: 'IntegrationStorage__accountName'
        value: integrationStorage.outputs.name
      }
      {
        name: 'FunctionAppUrl'
        value: 'https://${functionApp.outputs.defaultHostname}'
      }
    ]
  }
}

// ============================================================================
// RBAC Role Assignments
// ============================================================================

// Azure Service Bus Data Receiver role: 4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0
var serviceBusDataReceiverRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')

// Azure Service Bus Data Sender role: 69a216fc-b8fb-44d8-bc22-1f3c2cd27a39
var serviceBusDataSenderRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')

// Storage Blob Data Contributor role: ba92f5b4-2d11-453d-a403-e96b0029c9fe
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// Managed Identity needs Service Bus access
module serviceBusReceiverRole '../../modules/rbacAssignment.bicep' = {
  name: 'serviceBusReceiverRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityId
    roleDefinitionId: serviceBusDataReceiverRoleId
    principalType: 'ServicePrincipal'
  }
}

module serviceBusSenderRole '../../modules/rbacAssignment.bicep' = {
  name: 'serviceBusSenderRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityId
    roleDefinitionId: serviceBusDataSenderRoleId
    principalType: 'ServicePrincipal'
  }
}

// Managed Identity needs Integration Storage access
module integrationStorageRole '../../modules/rbacAssignment.bicep' = {
  name: 'integrationStorageRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityId
    roleDefinitionId: storageBlobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Integration resource group name')
output resourceGroupName string = integrationResourceGroup.name

@description('Service Bus Namespace name')
output serviceBusName string = serviceBus.outputs.name

@description('Service Bus Queue name')
output queueName string = serviceBus.outputs.queueNames[0]

@description('Function App name')
output functionAppName string = functionApp.outputs.name

@description('Logic App name')
output logicAppName string = logicApp.outputs.name

@description('Integration Storage Account name')
output integrationStorageName string = integrationStorage.outputs.name
