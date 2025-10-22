// Log Analytics Workspace Module
// Deploys an Azure Log Analytics workspace for diagnostics and monitoring

@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Azure region for the workspace')
param location string

@description('Tags to apply to the workspace')
param tags object = {}

@description('SKU name for the workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param skuName string = 'PerGB2018'

@description('Retention period in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Daily quota in GB (-1 for unlimited)')
param dailyQuotaGb int = -1

@description('Enable public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable public network access for query')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

// Deploy Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: dailyQuotaGb > 0 ? {
      dailyQuotaGb: dailyQuotaGb
    } : null
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

// Outputs
@description('Log Analytics Workspace resource ID')
output id string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace name')
output name string = logAnalyticsWorkspace.name

@description('Log Analytics Workspace customer ID')
output customerId string = logAnalyticsWorkspace.properties.customerId

@description('Log Analytics Workspace object')
output workspace object = logAnalyticsWorkspace
