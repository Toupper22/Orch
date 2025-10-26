// Standard Integration Template - SFTP Variant
// Focused template for SFTP-to-Blob integrations using Logic Apps
// No Service Bus, no Function Apps - just storage and Logic Apps with SFTP connector

targetScope = 'subscription'

// ============================================================================
// Parameters - Common
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
param integrationName string

@description('Common tags')
param tags object = {}

// ============================================================================
// Parameters - Storage
// ============================================================================

@description('Storage firewall default action (use Allow for initial deployment, then Deny)')
@allowed([
  'Allow'
  'Deny'
])
param storageFirewallDefault string = 'Allow'

@description('Integration storage containers')
param integrationStorageContainers array = []

@description('Integration storage tables')
param integrationStorageTables array = []

@description('Integration storage instance suffix (e.g., "int" for integration data)')
param integrationStorageInstance string = 'int'

// ============================================================================
// Parameters - SFTP Connection
// ============================================================================

@description('SFTP server host address')
param sftpHost string

@description('SFTP server port (default: 22)')
param sftpPort int = 22

@description('SFTP username')
param sftpUsername string

@description('SFTP password (leave empty if using SSH key)')
@secure()
param sftpPassword string = ''

@description('SSH private key (leave empty if using password)')
@secure()
param sftpSshPrivateKey string = ''

@description('SSH private key passphrase (if key is encrypted)')
@secure()
param sftpSshPrivateKeyPassphrase string = ''

@description('Root folder path on SFTP server')
param sftpRootFolder string = '/'

@description('Accept any SSH host key')
param sftpAcceptAnySshHostKey bool = true


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
  IntegrationType: 'SFTP'
})

// ============================================================================
// Reference Common Infrastructure (Existing Resources)
// ============================================================================

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
var commonManagedIdentityPrincipalId = commonManagedIdentity.properties.principalId  // Principal ID for RBAC
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

module integrationStorageNaming '../modules/naming.bicep' = {
  name: 'integrationStorageNaming'
  scope: integrationResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    workloadName: integrationName
    resourceType: 'st'
    instance: integrationStorageInstance
    useShortNames: true
  }
}

module keyVaultNaming '../modules/naming.bicep' = {
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

module integrationKeyVault '../modules/keyVault.bicep' = {
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
// Integration Storage Account
// ============================================================================

// Integration Data Storage Account
module integrationStorage '../modules/storageAccount.bicep' = {
  name: 'integrationStorage'
  scope: integrationResourceGroup
  params: {
    storageAccountName: integrationStorageNaming.outputs.name
    location: location
    tags: union(commonTags, { Purpose: 'Integration Data Storage' })
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    containers: integrationStorageContainers
    tables: integrationStorageTables
    networkAclDefaultAction: storageFirewallDefault
    ipRules: storageFirewallDefault == 'Deny' ? [
      '217.149.56.100'
    ] : []
    virtualNetworkRules: [
      integrationSubnetId
    ]
  }
}

// ============================================================================
// Store Storage Account Connection String in Integration Key Vault
// ============================================================================

// Integration Storage Connection String
module integrationStorageConnectionStringSecret '../modules/storageConnectionStringSecret.bicep' = {
  name: 'integrationStorageConnectionStringSecret'
  scope: integrationResourceGroup
  params: {
    keyVaultName: integrationKeyVault.outputs.name
    secretName: 'IntegrationStorageConnectionString'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: integrationStorageNaming.outputs.name
  }
}

// ============================================================================
// RBAC Role Assignments
// ============================================================================

// Storage Blob Data Contributor role: ba92f5b4-2d11-453d-a403-e96b0029c9fe
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// Storage Table Data Contributor role: 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3
var storageTableDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')

// Managed Identity needs Integration Storage access (Blob)
module integrationStorageBlobRole '../modules/rbacAssignment.bicep' = {
  name: 'integrationStorageBlobRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: storageBlobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// Managed Identity needs Integration Storage access (Table)
module integrationStorageTableRole '../modules/rbacAssignment.bicep' = {
  name: 'integrationStorageTableRole'
  scope: integrationResourceGroup
  params: {
    principalId: commonManagedIdentityPrincipalId
    roleDefinitionId: storageTableDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// API Connections for Logic Apps
// ============================================================================

// Azure Blob Storage API Connection
module blobApiConnection './shared/apiConnections/blob.bicep' = {
  name: 'blobApiConnection'
  scope: integrationResourceGroup
  params: {
    connectionName: '${prefix}-${environment}-${integrationName}-blob-conn'
    location: location
    tags: commonTags
    displayName: '${integrationName} Blob Storage'
    storageAccountResourceGroup: integrationResourceGroup.name
    storageAccountName: integrationStorage.outputs.name
  }
}

// SFTP API Connection
module sftpApiConnection './shared/apiConnections/sftp.bicep' = {
  name: 'sftpApiConnection'
  scope: integrationResourceGroup
  params: {
    connectionName: '${prefix}-${environment}-${integrationName}-sftp-conn'
    location: location
    tags: commonTags
    displayName: '${integrationName} SFTP'
    sftpHost: sftpHost
    sftpPort: sftpPort
    sftpUsername: sftpUsername
    sftpPassword: sftpPassword
    sftpSshPrivateKey: sftpSshPrivateKey
    sftpSshPrivateKeyPassphrase: sftpSshPrivateKeyPassphrase
    sftpRootFolder: sftpRootFolder
    acceptAnySshHostKey: sftpAcceptAnySshHostKey
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Integration resource group name')
output resourceGroupName string = integrationResourceGroup.name

@description('Integration Storage Account name')
output integrationStorageName string = integrationStorage.outputs.name

@description('Integration Key Vault name')
output integrationKeyVaultName string = integrationKeyVault.outputs.name

@description('Integration Key Vault URI')
output integrationKeyVaultUri string = integrationKeyVault.outputs.uri

@description('Blob API Connection ID')
output blobApiConnectionId string = blobApiConnection.outputs.id

@description('Blob API Connection name')
output blobApiConnectionName string = blobApiConnection.outputs.name

@description('SFTP API Connection ID')
output sftpApiConnectionId string = sftpApiConnection.outputs.id

@description('SFTP API Connection name')
output sftpApiConnectionName string = sftpApiConnection.outputs.name
