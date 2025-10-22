// API Connection Module
// Creates API connections for Logic Apps Standard to connect to Azure services

@description('Name of the API connection')
param connectionName string

@description('Azure region for the connection')
param location string

@description('Tags to apply to the connection')
param tags object = {}

@description('Connection type (azuretables, azureblob, office365, etc.)')
param connectionType string

@description('Display name for the connection')
param displayName string

@description('Connection parameters - varies by connection type')
@secure()
param parameterValues object = {}

@description('Connection parameter values that are not sensitive')
param additionalParameterValues object = {}

// API Connection display names and IDs by type
var connectionTypes = {
  azuretables: {
    id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azuretables')
    displayName: 'Azure Table Storage'
  }
  azureblob: {
    id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
    displayName: 'Azure Blob Storage'
  }
  servicebus: {
    id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    displayName: 'Service Bus'
  }
  office365: {
    id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    displayName: 'Office 365 Outlook'
  }
  sql: {
    id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'sql')
    displayName: 'SQL Server'
  }
}

// Deploy API Connection
resource apiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    displayName: !empty(displayName) ? displayName : connectionTypes[connectionType].displayName
    api: {
      id: connectionTypes[connectionType].id
    }
    parameterValues: union(parameterValues, additionalParameterValues)
  }
}

// Outputs
@description('API Connection resource ID')
output id string = apiConnection.id

@description('API Connection name')
output name string = apiConnection.name

@description('API Connection status link')
output statusLink string = length(apiConnection.properties.statuses) > 0 ? apiConnection.properties.statuses[0].status : 'Unknown'

@description('API Connection object')
output connection object = apiConnection
