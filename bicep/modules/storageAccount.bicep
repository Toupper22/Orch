// Storage Account Module
// Deploys an Azure Storage Account with containers and security best practices

@description('Name of the Storage Account')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Azure region for the Storage Account')
param location string

@description('Tags to apply to the Storage Account')
param tags object = {}

@description('Storage Account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Storage Account kind')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
])
param kind string = 'StorageV2'

@description('Access tier for blob storage')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Minimum TLS version')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Allow blob public access')
param allowBlobPublicAccess bool = false

@description('Enable HTTPS traffic only')
param supportsHttpsTrafficOnly bool = true

@description('Enable hierarchical namespace (Data Lake)')
param isHnsEnabled bool = false

@description('Blob containers to create')
param containers array = []

@description('Table storage tables to create')
param tables array = []

@description('File shares to create')
param fileShares array = []

@description('Enable diagnostic settings')
param enableDiagnostics bool = false

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Network ACL default action')
@allowed([
  'Allow'
  'Deny'
])
param networkAclDefaultAction string = 'Deny'

@description('IP rules for storage account access')
param ipRules array = []

@description('Virtual network rules for storage account access')
param virtualNetworkRules array = []

// Deploy Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    isHnsEnabled: isHnsEnabled
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: networkAclDefaultAction
      bypass: 'AzureServices'
      ipRules: [for ipRule in ipRules: {
        value: ipRule
        action: 'Allow'
      }]
      virtualNetworkRules: [for vnetRule in virtualNetworkRules: {
        id: vnetRule
        action: 'Allow'
      }]
    }
  }
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Create containers
resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in containers: {
  name: container.name
  parent: blobService
  properties: {
    publicAccess: container.?publicAccess ?? 'None'
    metadata: container.?metadata ?? {}
  }
}]

// Table Service
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = if (length(tables) > 0) {
  name: 'default'
  parent: storageAccount
  properties: {}
}

// Create tables
resource storageTables 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = [for table in tables: if (length(tables) > 0) {
  name: table.name
  parent: tableService
  properties: {}
}]

// File Service
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = if (length(fileShares) > 0) {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Create file shares
resource storageFileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for fileShare in fileShares: if (length(fileShares) > 0) {
  name: fileShare.name
  parent: fileService
  properties: {
    shareQuota: fileShare.?shareQuota ?? 5120
    enabledProtocols: fileShare.?enabledProtocols ?? 'SMB'
  }
}]

// Diagnostic Settings for Blob Service
resource blobDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  name: '${storageAccountName}-blob-diagnostics'
  scope: blobService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// Outputs
@description('Storage Account resource ID')
output id string = storageAccount.id

@description('Storage Account name')
output name string = storageAccount.name

@description('Primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('Primary endpoints object')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('Storage Account object')
output storageAccount object = storageAccount
