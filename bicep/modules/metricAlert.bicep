@description('The name of the metric alert')
param name string

@description('The location where the resource will be deployed')
param location string = 'global'

@description('Tags to apply to the resource')
param tags object = {}

@description('The description of the alert')
param alertDescription string = ''

@description('The severity of the alert (0=Critical, 1=Error, 2=Warning, 3=Informational, 4=Verbose)')
@minValue(0)
@maxValue(4)
param severity int = 2

@description('Whether the alert is enabled')
param enabled bool = true

@description('The resource IDs to scope the alert to')
param scopes array

@description('How often the metric alert is evaluated (ISO 8601 duration)')
param evaluationFrequency string = 'PT5M'

@description('The period of time used to monitor alert activity (ISO 8601 duration)')
param windowSize string = 'PT15M'

@description('The criteria for the alert')
param criteria object

@description('The IDs of the action groups to trigger')
param actionGroupIds array = []

@description('Whether to auto-mitigate the alert')
param autoMitigate bool = true

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: alertDescription
    severity: severity
    enabled: enabled
    scopes: scopes
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: criteria
    autoMitigate: autoMitigate
    actions: [for actionGroupId in actionGroupIds: {
      actionGroupId: actionGroupId
      webHookProperties: {}
    }]
  }
}

@description('The resource ID of the metric alert')
output id string = metricAlert.id

@description('The name of the metric alert')
output name string = metricAlert.name
