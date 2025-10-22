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

// Reference common Application Insights
resource commonApplicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${prefix}-${environment}-${locationShort}-appi'
  scope: commonResourceGroup
}

// Reference integration subnet (first subnet in common VNet)
resource integrationSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'integration-subnet'
  parent: commonVNet
}

// IDs for passing to modules
var commonAppServicePlanId = commonAppServicePlan.id
var commonManagedIdentityId = commonManagedIdentity.properties.principalId  // Principal ID for RBAC, not resource ID
var integrationSubnetId = integrationSubnet.id
var commonApplicationInsightsConnectionString = commonApplicationInsights.properties.ConnectionString

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

module functionStorageNaming '../../modules/naming.bicep' = {
  name: 'functionStorageNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'st'
    useShortNames: true
  }
}

module archiveStorageNaming '../../modules/naming.bicep' = {
  name: 'archiveStorageNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'st'
    instance: 'arc'
    useShortNames: true
  }
}

module keyVaultNaming '../../modules/naming.bicep' = {
  name: 'keyVaultNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'kv'
  }
}

// ============================================================================
// Integration-Specific Key Vault
// ============================================================================

module integrationKeyVault '../../modules/keyVault.bicep' = {
  name: 'integrationKeyVault'
  scope: integrationResourceGroup
  params: {
    keyVaultName: replace(keyVaultNaming.outputs.name, '-', '')
    location: location
    tags: union(commonTags, { Purpose: 'Integration Secrets' })
    skuName: 'standard'
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: commonManagedIdentity.properties.principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
          keys: []
          certificates: []
        }
      }
    ]
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'prod'
  }
}

// ============================================================================
// Integration Storage Accounts
// ============================================================================

// Function App Storage Account
module functionStorage '../../modules/storageAccount.bicep' = {
  name: 'functionStorage'
  scope: integrationResourceGroup
  params: {
    storageAccountName: functionStorageNaming.outputs.name
    location: location
    tags: union(commonTags, { Purpose: 'Function App Storage' })
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
    tables: [
      {
        name: 'Values'
      }
      {
        name: 'Conversions'
      }
    ]
    networkAclDefaultAction: 'Deny'
    ipRules: [
      '217.149.56.100'
    ]
    virtualNetworkRules: [
      integrationSubnetId
    ]
  }
}

// Archive Storage Account
module archiveStorage '../../modules/storageAccount.bicep' = {
  name: 'archiveStorage'
  scope: integrationResourceGroup
  params: {
    storageAccountName: archiveStorageNaming.outputs.name
    location: location
    tags: union(commonTags, { Purpose: 'Archive Storage' })
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Cool'
    containers: [
      {
        name: 'archive'
        publicAccess: 'None'
      }
      {
        name: 'audit'
        publicAccess: 'None'
      }
    ]
    tables: [
      {
        name: 'Values'
      }
      {
        name: 'Conversions'
      }
    ]
    networkAclDefaultAction: 'Deny'
    ipRules: [
      '217.149.56.100'
    ]
    virtualNetworkRules: [
      integrationSubnetId
    ]
  }
}

// ============================================================================
// Store Storage Account Keys and Connection Strings in Integration Key Vault
// ============================================================================

// Function Storage Account Key
module functionStorageKeySecret '../../modules/storageKeySecret.bicep' = {
  name: 'functionStorageKeySecret'
  scope: integrationResourceGroup
  params: {
    keyVaultName: integrationKeyVault.outputs.name
    secretName: 'FunctionStorageAccountKey'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: functionStorageNaming.outputs.name
  }
}

// Archive Storage Account Key
module archiveStorageKeySecret '../../modules/storageKeySecret.bicep' = {
  name: 'archiveStorageKeySecret'
  scope: integrationResourceGroup
  params: {
    keyVaultName: integrationKeyVault.outputs.name
    secretName: 'ArchiveStorageAccountKey'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: archiveStorageNaming.outputs.name
  }
}

// Function Storage Connection String
module functionStorageConnectionStringSecret '../../modules/storageConnectionStringSecret.bicep' = {
  name: 'functionStorageConnectionStringSecret'
  scope: integrationResourceGroup
  params: {
    keyVaultName: integrationKeyVault.outputs.name
    secretName: 'FunctionStorageConnectionString'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: functionStorageNaming.outputs.name
  }
}

// Archive Storage Connection String
module archiveStorageConnectionStringSecret '../../modules/storageConnectionStringSecret.bicep' = {
  name: 'archiveStorageConnectionStringSecret'
  scope: integrationResourceGroup
  params: {
    keyVaultName: integrationKeyVault.outputs.name
    secretName: 'ArchiveStorageConnectionString'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: archiveStorageNaming.outputs.name
  }
}

// ============================================================================
// Service Bus
// ============================================================================

module serviceBus '../../modules/serviceBus.bicep' = {
  name: 'serviceBus'
  scope: integrationResourceGroup
  params: {
    serviceBusName: replace(serviceBusNaming.outputs.name, '-', '')
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
    storageAccountName: functionStorage.outputs.name
    appInsightsConnectionString: commonApplicationInsightsConnectionString
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
        name: 'FunctionStorage__accountName'
        value: functionStorage.outputs.name
      }
      {
        name: 'ArchiveStorage__accountName'
        value: archiveStorage.outputs.name
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
        name: 'FunctionStorage__accountName'
        value: functionStorage.outputs.name
      }
      {
        name: 'ArchiveStorage__accountName'
        value: archiveStorage.outputs.name
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

// Managed Identity needs Function Storage access
module functionStorageRole '../../modules/rbacAssignment.bicep' = {
  name: 'functionStorageRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityId
    roleDefinitionId: storageBlobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// Managed Identity needs Archive Storage access
module archiveStorageRole '../../modules/rbacAssignment.bicep' = {
  name: 'archiveStorageRole'
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

@description('Function Storage Account name')
output functionStorageName string = functionStorage.outputs.name

@description('Archive Storage Account name')
output archiveStorageName string = archiveStorage.outputs.name

@description('Integration Key Vault name')
output integrationKeyVaultName string = integrationKeyVault.outputs.name

@description('Integration Key Vault URI')
output integrationKeyVaultUri string = integrationKeyVault.outputs.uri
