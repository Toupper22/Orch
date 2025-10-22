// Storage Connection String Secret Module
// Creates a Key Vault secret containing a storage account connection string

@description('Name of the existing Key Vault')
param keyVaultName string

@description('Name of the secret')
param secretName string

@description('Resource group containing the storage account')
param storageAccountResourceGroup string

@description('Name of the storage account')
param storageAccountName string

@description('Tags to apply to the secret')
param tags object = {}

// Reference to existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Build the connection string with listKeys
var connectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId(storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName), '2023-01-01').keys[0].value};EndpointSuffix=core.windows.net'

// Create the secret
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  tags: tags
  properties: {
    value: connectionString
  }
}

// Outputs
@description('Secret resource ID')
output id string = secret.id

@description('Secret name')
output name string = secret.name

@description('Secret URI')
output uri string = secret.properties.secretUri
