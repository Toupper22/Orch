// App Service Plan Module
// Deploys an Azure App Service Plan for hosting Function Apps and Logic Apps

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Azure region for the App Service Plan')
param location string

@description('Tags to apply to the App Service Plan')
param tags object = {}

@description('App Service Plan SKU name')
@allowed([
  'Y1'          // Consumption (Function Apps)
  'EP1'         // Elastic Premium 1
  'EP2'         // Elastic Premium 2
  'EP3'         // Elastic Premium 3
  'WS1'         // Workflow Standard 1 (Logic Apps)
  'WS2'         // Workflow Standard 2 (Logic Apps)
  'WS3'         // Workflow Standard 3 (Logic Apps)
  'S1'          // Standard S1
  'S2'          // Standard S2
  'S3'          // Standard S3
  'P1V2'        // Premium V2 P1
  'P2V2'        // Premium V2 P2
  'P3V2'        // Premium V2 P3
])
param skuName string = 'Y1'

@description('App Service Plan kind')
@allowed([
  'functionapp'
  'elastic'
  'workflow'
  'app'
])
param kind string = 'functionapp'

@description('Enable zone redundancy (requires Premium V2 or higher)')
param zoneRedundant bool = false

@description('Maximum number of workers (elastic scale)')
param maximumElasticWorkerCount int = 1

@description('Number of workers (pre-warmed instances for Elastic Premium)')
param targetWorkerCount int = 0

// SKU tier mapping
var skuTierMap = {
  Y1: 'Dynamic'
  EP1: 'ElasticPremium'
  EP2: 'ElasticPremium'
  EP3: 'ElasticPremium'
  WS1: 'WorkflowStandard'
  WS2: 'WorkflowStandard'
  WS3: 'WorkflowStandard'
  S1: 'Standard'
  S2: 'Standard'
  S3: 'Standard'
  P1V2: 'PremiumV2'
  P2V2: 'PremiumV2'
  P3V2: 'PremiumV2'
}

// Deploy App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: skuName
    tier: skuTierMap[skuName]
  }
  properties: {
    reserved: false
    zoneRedundant: zoneRedundant
    maximumElasticWorkerCount: skuName == 'Y1' ? 1 : maximumElasticWorkerCount
    targetWorkerCount: skuName == 'Y1' ? 0 : targetWorkerCount
  }
}

// Outputs
@description('App Service Plan resource ID')
output id string = appServicePlan.id

@description('App Service Plan name')
output name string = appServicePlan.name

@description('App Service Plan SKU')
output sku object = appServicePlan.sku

@description('App Service Plan object')
output appServicePlan object = appServicePlan
