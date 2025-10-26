// Azure Blob Storage API Connection Module
// Specialized module for creating Azure Blob Storage API connections for Logic Apps

@description('Name of the API connection')
param connectionName string

@description('Azure region for the connection')
param location string

@description('Tags to apply to the connection')
param tags object = {}

@description('Display name for the connection')
param displayName string = 'Azure Blob Storage'

@description('Resource group containing the storage account')
param storageAccountResourceGroup string

@description('Storage account name')
param storageAccountName string

// Get the storage account key
var storageAccountKey = listKeys(resourceId(storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName), '2023-01-01').keys[0].value

// Deploy Blob API Connection
resource blobConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    displayName: displayName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
    parameterValues: {
      accountName: storageAccountName
      accessKey: storageAccountKey
    }
  }
}

// Outputs
@description('API Connection resource ID')
output id string = blobConnection.id

@description('API Connection name')
output name string = blobConnection.name

@description('Full connection object for Logic App parameters')
output connectionInfo object = {
  id: blobConnection.id
  connectionId: blobConnection.id
  connectionName: blobConnection.name
  connectionProperties: {
    authentication: {
      type: 'Raw'
    }
  }
}
