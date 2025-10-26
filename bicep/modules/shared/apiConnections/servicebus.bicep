// Service Bus API Connection Module
// Specialized module for creating Service Bus API connections for Logic Apps

@description('Name of the API connection')
param connectionName string

@description('Azure region for the connection')
param location string

@description('Tags to apply to the connection')
param tags object = {}

@description('Display name for the connection')
param displayName string = 'Service Bus'

@description('Service Bus namespace name')
param serviceBusNamespace string

@description('Resource group containing the Service Bus namespace')
param serviceBusResourceGroup string

// Get the Service Bus connection string
var serviceBusConnectionString = listKeys(resourceId(serviceBusResourceGroup, 'Microsoft.ServiceBus/namespaces/authorizationRules', serviceBusNamespace, 'RootManageSharedAccessKey'), '2021-11-01').primaryConnectionString

// Deploy Service Bus API Connection
resource serviceBusConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  properties: {
    displayName: displayName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    }
    parameterValues: {
      connectionString: serviceBusConnectionString
    }
  }
}

// Outputs
@description('API Connection resource ID')
output id string = serviceBusConnection.id

@description('API Connection name')
output name string = serviceBusConnection.name

@description('Full connection object for Logic App parameters')
output connectionInfo object = {
  id: serviceBusConnection.id
  connectionId: serviceBusConnection.id
  connectionName: serviceBusConnection.name
  connectionProperties: {
    authentication: {
      type: 'Raw'
    }
  }
}
