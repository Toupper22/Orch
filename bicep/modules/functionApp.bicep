// Function App Module
// Deploys an Azure Function App with VNet integration

@description('Name of the Function App')
param functionAppName string

@description('Azure region for the Function App')
param location string

@description('Tags to apply to the Function App')
param tags object = {}

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Storage Account name for Function App')
param storageAccountName string

@description('Application Insights Connection String')
param appInsightsConnectionString string = ''

@description('Managed Identity resource ID')
param managedIdentityId string = ''

@description('Managed Identity Client ID for identity-based storage connections')
param managedIdentityClientId string = ''

@description('VNet integration subnet ID')
param vnetIntegrationSubnetId string = ''

@description('Application settings')
param appSettings array = []

@description('Enable VNet integration')
param enableVNetIntegration bool = true

// Deploy Function App
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: !empty(managedIdentityId) ? 'UserAssigned' : 'SystemAssigned'
    userAssignedIdentities: !empty(managedIdentityId) ? {
      '${managedIdentityId}': {}
    } : null
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    virtualNetworkSubnetId: enableVNetIntegration && !empty(vnetIntegrationSubnetId) ? vnetIntegrationSubnetId : null
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      use32BitWorkerProcess: false
      alwaysOn: true
      appSettings: concat([
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'DOTNET_ISOLATED_DEBUG'
          value: 'false'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'AzureWebJobsStorage__credential'
          value: 'managedidentity'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'AzureWebJobsStorage__blobServiceUri'
          value: 'https://${storageAccountName}.blob.${environment().suffixes.storage}'
        }
        {
          name: 'AzureWebJobsStorage__queueServiceUri'
          value: 'https://${storageAccountName}.queue.${environment().suffixes.storage}'
        }
        {
          name: 'AzureWebJobsStorage__tableServiceUri'
          value: 'https://${storageAccountName}.table.${environment().suffixes.storage}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2023-01-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2023-01-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
      ], !empty(appInsightsConnectionString) ? [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ] : [], appSettings)
    }
  }
}

// VNet Integration Configuration
resource vnetConnection 'Microsoft.Web/sites/networkConfig@2023-01-01' = if (enableVNetIntegration && !empty(vnetIntegrationSubnetId)) {
  name: 'virtualNetwork'
  parent: functionApp
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// Outputs
@description('Function App resource ID')
output id string = functionApp.id

@description('Function App name')
output name string = functionApp.name

@description('Function App default hostname')
output defaultHostname string = functionApp.properties.defaultHostName

@description('Function App principal ID')
output principalId string = !empty(managedIdentityId) ? '' : functionApp.identity.principalId

@description('Function App object')
output functionApp object = functionApp
