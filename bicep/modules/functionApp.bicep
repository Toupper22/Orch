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

@description('VNet integration subnet ID')
param vnetIntegrationSubnetId string = ''

@description('Runtime stack')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'node'
  'python'
  'java'
  'powershell'
])
param runtime string = 'dotnet-isolated'

@description('Runtime version')
param runtimeVersion string = '8.0'

@description('Application settings')
param appSettings array = []

@description('Enable VNet integration')
param enableVNetIntegration bool = true

// Deploy Function App
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
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
      netFrameworkVersion: runtime == 'dotnet' || runtime == 'dotnet-isolated' ? 'v${runtimeVersion}' : null
      nodeVersion: runtime == 'node' ? runtimeVersion : null
      pythonVersion: runtime == 'python' ? runtimeVersion : null
      javaVersion: runtime == 'java' ? runtimeVersion : null
      powerShellVersion: runtime == 'powershell' ? runtimeVersion : null
      use32BitWorkerProcess: false
      alwaysOn: true
      appSettings: concat([
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
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
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
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
