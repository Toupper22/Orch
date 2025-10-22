// Logic App Standard Module
// Deploys an Azure Logic App (Standard) with VNet integration
//
// NOTE: This uses Logic App Standard (not Consumption tier) which:
// - Runs on an App Service Plan (cost-effective tiers like B1 or S2)
// - Supports VNet integration (Consumption tier does NOT support VNet)
// - Provides better performance and more features
// - Uses the same App Service Plan as Function Apps for cost efficiency

@description('Name of the Logic App')
param logicAppName string

@description('Azure region for the Logic App')
param location string

@description('Tags to apply to the Logic App')
param tags object = {}

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Storage Account name for Logic App')
param storageAccountName string

@description('Application Insights Connection String')
param appInsightsConnectionString string = ''

@description('Managed Identity resource ID')
param managedIdentityId string = ''

@description('VNet integration subnet ID')
param vnetIntegrationSubnetId string = ''

@description('Application settings')
param appSettings array = []

@description('Enable VNet integration')
param enableVNetIntegration bool = true

// Deploy Logic App (Standard)
resource logicApp 'Microsoft.Web/sites@2023-01-01' = {
  name: logicAppName
  location: location
  tags: tags
  kind: 'functionapp,workflowapp'
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
      netFrameworkVersion: 'v6.0'
      use32BitWorkerProcess: false
      alwaysOn: true
      appSettings: concat([
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=***;EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(logicAppName)
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
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
  parent: logicApp
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// Outputs
@description('Logic App resource ID')
output id string = logicApp.id

@description('Logic App name')
output name string = logicApp.name

@description('Logic App default hostname')
output defaultHostname string = logicApp.properties.defaultHostName

@description('Logic App principal ID')
output principalId string = !empty(managedIdentityId) ? '' : logicApp.identity.principalId

@description('Logic App object')
output logicApp object = logicApp
