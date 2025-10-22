@description('The name of the Application Insights resource')
param name string

@description('The location where the resource will be deployed')
param location string

@description('Tags to apply to the resource')
param tags object = {}

@description('The type of application being monitored')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Retention period in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90

@description('Daily data cap in GB (0 = unlimited)')
@minValue(0)
param dailyDataCapInGB int = 0

@description('Enable public network access')
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable public network access for query')
param publicNetworkAccessForQuery string = 'Enabled'

@description('Workspace ID to link Application Insights to (if using workspace-based)')
param workspaceResourceId string = ''

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: applicationType
  properties: {
    Application_Type: applicationType
    RetentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    WorkspaceResourceId: !empty(workspaceResourceId) ? workspaceResourceId : null
    IngestionMode: !empty(workspaceResourceId) ? 'LogAnalytics' : 'ApplicationInsights'
    Request_Source: 'rest'
    DisableIpMasking: false
    SamplingPercentage: 100
  }
}

// Data cap configuration
resource dataCapConfig 'Microsoft.Insights/components/currentbillingfeatures@2015-05-01' = if (dailyDataCapInGB > 0) {
  name: 'Basic'
  parent: applicationInsights
  properties: {
    CurrentBillingFeatures: 'Basic'
    DataVolumeCap: {
      Cap: dailyDataCapInGB
      WarningThreshold: 90
      StopSendNotificationWhenHitCap: false
    }
  }
}

@description('The resource ID of the Application Insights instance')
output id string = applicationInsights.id

@description('The name of the Application Insights instance')
output name string = applicationInsights.name

@description('The instrumentation key for the Application Insights instance')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string for the Application Insights instance')
output connectionString string = applicationInsights.properties.ConnectionString
