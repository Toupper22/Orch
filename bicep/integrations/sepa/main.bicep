// SEPA Integration - Main Template
// Deploys SEPA Integration Function App, Logic Apps, and supporting infrastructure

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
param integrationName string = 'sepa'

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

@description('Storage firewall default action (use Allow for initial deployment, then Deny)')
@allowed([
  'Allow'
  'Deny'
])
param storageFirewallDefault string = 'Allow'

// ============================================================================
// Variables
// ============================================================================

var resourceGroupName = '${prefix}-${environment}-${integrationName}-rg'

// Calculate common infrastructure resource names based on naming convention
var commonResourceGroupName = '${prefix}-${environment}-common-rg'
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
var commonManagedIdentityId = commonManagedIdentity.id  // Full resource ID for identity assignment
var commonManagedIdentityPrincipalId = commonManagedIdentity.properties.principalId  // Principal ID for RBAC
var commonManagedIdentityClientId = commonManagedIdentity.properties.clientId  // Client ID for identity-based connections
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
        objectId: commonManagedIdentityPrincipalId
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
    containers: []
    tables: []
    fileShares: [
      {
        name: toLower(functionAppNaming.outputs.name)
        shareQuota: 5120
      }
    ]
    networkAclDefaultAction: storageFirewallDefault
    ipRules: storageFirewallDefault == 'Deny' ? [
      '217.149.56.100'
    ] : []
    virtualNetworkRules: storageFirewallDefault == 'Deny' ? [
      integrationSubnetId
    ] : []
  }
}

// Archive Storage Account (for SEPA files)
module archiveStorage '../../modules/storageAccount.bicep' = {
  name: 'archiveStorage'
  scope: integrationResourceGroup
  params: {
    storageAccountName: archiveStorageNaming.outputs.name
    location: location
    tags: union(commonTags, { Purpose: 'SEPA Archive Storage' })
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    containers: [
      {
        name: 'sepa'
        publicAccess: 'None'
      }
      {
        name: 'sepa-processed'
        publicAccess: 'None'
      }
      {
        name: 'sepa-transformed'
        publicAccess: 'None'
      }
      {
        name: 'sepa-errors'
        publicAccess: 'None'
      }
    ]
    tables: [
      {
        name: 'ErrorLog'
      }
      {
        name: 'ProcessingLog'
      }
    ]
    networkAclDefaultAction: storageFirewallDefault
    ipRules: storageFirewallDefault == 'Deny' ? [
      '217.149.56.100'
    ] : []
    virtualNetworkRules: storageFirewallDefault == 'Deny' ? [
      integrationSubnetId
    ] : []
  }
}

// ============================================================================
// Store Storage Account Keys and Connection Strings in Integration Key Vault
// ============================================================================

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
        name: 'sepa-inbound'
        maxDeliveryCount: 10
        lockDuration: 'PT5M'
        defaultMessageTimeToLive: 'P7D'
      }
      {
        name: 'sepa-errors'
        maxDeliveryCount: 10
        lockDuration: 'PT5M'
        defaultMessageTimeToLive: 'P14D'
      }
    ]
  }
}

// ============================================================================
// Function App (SEPA Data Transformer)
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
    managedIdentityClientId: commonManagedIdentityClientId
    vnetIntegrationSubnetId: integrationSubnetId
    enableVNetIntegration: true
    appSettings: [
      {
        name: 'ServiceBusConnection__fullyQualifiedNamespace'
        value: '${serviceBus.outputs.name}.servicebus.windows.net'
      }
      {
        name: 'ArchiveStorage__accountName'
        value: archiveStorage.outputs.name
      }
      {
        name: 'KeyVaultUri'
        value: integrationKeyVault.outputs.uri
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

// Storage Table Data Contributor role: 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3
var storageTableDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')

// Managed Identity needs Service Bus access
module serviceBusReceiverRole '../../modules/rbacAssignment.bicep' = {
  name: 'serviceBusReceiverRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: serviceBusDataReceiverRoleId
    principalType: 'ServicePrincipal'
  }
}

module serviceBusSenderRole '../../modules/rbacAssignment.bicep' = {
  name: 'serviceBusSenderRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: serviceBusDataSenderRoleId
    principalType: 'ServicePrincipal'
  }
}

// Managed Identity needs Archive Storage access (Blob)
module archiveStorageBlobRole '../../modules/rbacAssignment.bicep' = {
  name: 'archiveStorageBlobRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: storageBlobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// Managed Identity needs Archive Storage access (Table)
module archiveStorageTableRole '../../modules/rbacAssignment.bicep' = {
  name: 'archiveStorageTableRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: storageTableDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// Website Contributor role for managed identity to restart Function App
var websiteContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'de139f84-1756-47ae-9be6-808fbbe84772')

module functionAppContributorRole '../../modules/rbacAssignment.bicep' = {
  name: 'functionAppContributorRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: websiteContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Post-Deployment: Restart Function App
// ============================================================================

module restartFunctionApp '../../modules/restartFunctionApp.bicep' = {
  name: 'restartFunctionApp'
  scope: integrationResourceGroup
  params: {
    functionAppName: functionAppNaming.outputs.name
    location: location
    managedIdentityId: commonManagedIdentityId
  }
  dependsOn: [
    archiveStorageBlobRole
    archiveStorageTableRole
    functionAppContributorRole
  ]
}

// ============================================================================
// Outputs
// ============================================================================

@description('Integration resource group name')
output resourceGroupName string = integrationResourceGroup.name

@description('Service Bus Namespace name')
output serviceBusName string = serviceBus.outputs.name

@description('Service Bus Queue names')
output queueNames array = serviceBus.outputs.queueNames

@description('Function App name')
output functionAppName string = functionApp.outputs.name

@description('Function Storage Account name')
output functionStorageName string = functionStorage.outputs.name

@description('Archive Storage Account name')
output archiveStorageName string = archiveStorage.outputs.name

@description('Integration Key Vault name')
output integrationKeyVaultName string = integrationKeyVault.outputs.name

@description('Integration Key Vault URI')
output integrationKeyVaultUri string = integrationKeyVault.outputs.uri
