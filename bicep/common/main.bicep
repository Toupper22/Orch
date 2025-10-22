// Main Common Infrastructure Deployment
// Deploys shared resources for Azure integrations with Dynamics 365 F&O
// Resources are deployed to a common resource group and shared across integrations

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================

@description('Customer/project prefix for resource naming')
param prefix string

@description('Environment name (dev, test, uat, prod)')
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
])
param environment string

@description('Azure region for resources')
param location string = deployment().location

@description('Azure region short code (e.g., weu for West Europe)')
param locationShort string

@description('Common tags to apply to all resources')
param tags object = {}

// Resource toggle parameters
@description('Deploy Key Vault')
param deployKeyVault bool = true

@description('Deploy Storage Account')
param deployStorageAccount bool = true

@description('Deploy App Service Plan')
param deployAppServicePlan bool = true

@description('Deploy Managed Identity')
param deployManagedIdentity bool = true

@description('Deploy Virtual Network')
param deployVirtualNetwork bool = true

@description('Deploy NAT Gateway')
param deployNatGateway bool = true

@description('Deploy Application Insights')
param deployApplicationInsights bool = true

@description('Deploy Log Analytics Workspace')
param deployLogAnalyticsWorkspace bool = true

@description('Deploy Service Bus Namespace')
param deployServiceBus bool = false

@description('Deploy API Connections for Logic Apps')
param deployApiConnections bool = true

// Key Vault parameters
@description('Key Vault SKU')
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'

@description('Key Vault soft delete retention in days')
param keyVaultSoftDeleteRetentionInDays int = 90

// Storage Account parameters
@description('Storage Account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param storageAccountSku string = 'Standard_LRS'

@description('Storage containers to create')
param storageContainers array = [
  {
    name: 'integration-files'
    publicAccess: 'None'
  }
  {
    name: 'logs'
    publicAccess: 'None'
  }
]

@description('Storage tables to create')
param storageTables array = [
  {
    name: 'Configuration'
  }
  {
    name: 'Logs'
  }
]

// App Service Plan parameters
@description('App Service Plan SKU')
@allowed([
  'Y1'
  'B1'
  'B2'
  'B3'
  'EP1'
  'EP2'
  'EP3'
  'WS1'
  'WS2'
  'WS3'
  'S1'
  'S2'
  'S3'
  'P1V2'
  'P2V2'
  'P3V2'
])
param appServicePlanSku string = 'B1'

@description('App Service Plan kind')
@allowed([
  'functionapp'
  'elastic'
  'workflow'
  'app'
])
param appServicePlanKind string = 'functionapp'

// Diagnostics parameters
@description('Enable diagnostic settings')
param enableDiagnostics bool = false

@description('External Log Analytics Workspace ID for diagnostics (leave empty to use the deployed workspace)')
param externalLogAnalyticsWorkspaceId string = ''

// Log Analytics Workspace parameters
@description('Log Analytics Workspace SKU')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param logAnalyticsWorkspaceSku string = 'PerGB2018'

@description('Log Analytics Workspace retention period in days')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionInDays int = 90

@description('Log Analytics Workspace daily quota in GB (-1 for unlimited)')
param logAnalyticsDailyQuotaGb int = -1

// Service Bus parameters
@description('Service Bus SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string = 'Standard'

@description('Service Bus capacity (only for Premium SKU)')
@allowed([
  1
  2
  4
  8
  16
])
param serviceBusCapacity int = 1

// Network parameters
@description('Virtual Network address prefixes')
param vnetAddressPrefixes array = [
  '10.0.0.0/16'
]

@description('Subnets configuration')
param subnets array = [
  {
    name: 'integration-subnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'private-endpoint-subnet'
    addressPrefix: '10.0.2.0/24'
  }
]

@description('NAT Gateway idle timeout in minutes')
param natGatewayIdleTimeoutInMinutes int = 4

// Application Insights parameters
@description('Application Insights retention period in days')
@minValue(30)
@maxValue(730)
param applicationInsightsRetentionInDays int = 90

@description('Email addresses for alert notifications')
param alertEmailReceivers array = []

@description('Enable default metric alerts')
param enableDefaultAlerts bool = true

// ============================================================================
// Variables
// ============================================================================

var resourceGroupName = '${prefix}-${environment}-common-rg'

var commonTags = union(tags, {
  Environment: environment
  ManagedBy: 'Bicep'
})

// Determine which Log Analytics Workspace to use
var logAnalyticsWorkspaceId = !empty(externalLogAnalyticsWorkspaceId) ? externalLogAnalyticsWorkspaceId : (deployLogAnalyticsWorkspace ? logAnalyticsWorkspace!.outputs.id : '')

// Storage account name (must be calculated here for use in listKeys)
// Pattern: {prefix}{env}{locationShort}st (no dashes, lowercase)
var storageAccountNameCalculated = toLower(replace('${prefix}${environment}${locationShort}st', '-', ''))

// ============================================================================
// Resource Group
// ============================================================================

resource commonResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

// ============================================================================
// Naming Modules
// ============================================================================

module keyVaultNaming '../modules/naming.bicep' = if (deployKeyVault) {
  name: 'keyVaultNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'kv'
  }
}

module storageAccountNaming '../modules/naming.bicep' = if (deployStorageAccount) {
  name: 'storageAccountNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'st'
    useShortNames: true
  }
}

module appServicePlanNaming '../modules/naming.bicep' = if (deployAppServicePlan) {
  name: 'appServicePlanNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'plan'
  }
}

module managedIdentityNaming '../modules/naming.bicep' = if (deployManagedIdentity) {
  name: 'managedIdentityNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'id'
  }
}

module virtualNetworkNaming '../modules/naming.bicep' = if (deployVirtualNetwork) {
  name: 'virtualNetworkNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'vnet'
  }
}

module natGatewayNaming '../modules/naming.bicep' = if (deployNatGateway) {
  name: 'natGatewayNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'nat'
  }
}

module publicIpNaming '../modules/naming.bicep' = if (deployNatGateway) {
  name: 'publicIpNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'pip'
  }
}

module applicationInsightsNaming '../modules/naming.bicep' = if (deployApplicationInsights) {
  name: 'applicationInsightsNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'appi'
  }
}

module actionGroupNaming '../modules/naming.bicep' = if (deployApplicationInsights && length(alertEmailReceivers) > 0) {
  name: 'actionGroupNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'ag'
  }
}

module logAnalyticsWorkspaceNaming '../modules/naming.bicep' = if (deployLogAnalyticsWorkspace) {
  name: 'logAnalyticsWorkspaceNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'log'
  }
}

module serviceBusNaming '../modules/naming.bicep' = if (deployServiceBus) {
  name: 'serviceBusNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'sb'
  }
}

module apiConnectionNaming '../modules/naming.bicep' = if (deployApiConnections && deployStorageAccount) {
  name: 'apiConnectionNaming'
  scope: commonResourceGroup
  params: {
    prefix: prefix
    environment: environment
    locationShort: locationShort
    resourceType: 'apic'
  }
}

// ============================================================================
// Managed Identity (deployed first for RBAC assignments)
// ============================================================================

module managedIdentity '../modules/managedIdentity.bicep' = if (deployManagedIdentity) {
  name: 'managedIdentity'
  scope: commonResourceGroup
  params: {
    managedIdentityName: replace(managedIdentityNaming!.outputs.name, '-', '')
    location: location
    tags: commonTags
    assignKeyVaultSecretsUser: false // Will be assigned after Key Vault is created
    assignStorageBlobDataContributor: false // Will be assigned after Storage Account is created
  }
}

// ============================================================================
// Key Vault
// ============================================================================

module keyVault '../modules/keyVault.bicep' = if (deployKeyVault) {
  name: 'keyVault'
  scope: commonResourceGroup
  params: {
    keyVaultName: replace(keyVaultNaming!.outputs.name, '-', '')
    location: location
    tags: commonTags
    skuName: keyVaultSku
    enableRbacAuthorization: false
    accessPolicies: deployManagedIdentity ? [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity!.outputs.principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
          keys: []
          certificates: []
        }
      }
    ] : []
    enableSoftDelete: true
    softDeleteRetentionInDays: keyVaultSoftDeleteRetentionInDays
    enablePurgeProtection: environment == 'prod'
    enableDiagnostics: enableDiagnostics
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [
        {
          value: '217.149.56.100'
        }
      ]
      virtualNetworkRules: deployVirtualNetwork ? [
        {
          id: '${virtualNetwork!.outputs.id}/subnets/integration-subnet'
          ignoreMissingVnetServiceEndpoint: false
        }
      ] : []
    }
  }
}

// ============================================================================
// Storage Account
// ============================================================================

module storageAccount '../modules/storageAccount.bicep' = if (deployStorageAccount) {
  name: 'storageAccount'
  scope: commonResourceGroup
  dependsOn: [
    managedIdentity
  ]
  params: {
    storageAccountName: storageAccountNameCalculated
    location: location
    tags: commonTags
    skuName: storageAccountSku
    kind: 'StorageV2'
    accessTier: 'Hot'
    containers: storageContainers
    tables: storageTables
    enableDiagnostics: enableDiagnostics
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    networkAclDefaultAction: 'Deny'
    ipRules: [
      '217.149.56.100'
    ]
    virtualNetworkRules: deployVirtualNetwork ? [
      '${virtualNetwork!.outputs.id}/subnets/integration-subnet'
    ] : []
  }
}

// ============================================================================
// API Connections for Logic Apps
// ============================================================================

// API Connection to Common Storage Account Tables
module storageTablesApiConnection '../modules/apiConnection.bicep' = if (deployApiConnections && deployStorageAccount) {
  name: 'storageTablesApiConnection'
  scope: commonResourceGroup
  params: {
    connectionName: '${apiConnectionNaming!.outputs.name}-tables'
    location: location
    tags: union(commonTags, { Purpose: 'Logic Apps Table Storage Access' })
    connectionType: 'azuretables'
    displayName: 'Common Storage Tables'
    storageAccountResourceGroup: commonResourceGroup.name
    storageAccountName: storageAccountNameCalculated
    parameterValues: {}
    additionalParameterValues: {}
  }
}

// ============================================================================
// App Service Plan
// ============================================================================

module appServicePlan '../modules/appServicePlan.bicep' = if (deployAppServicePlan) {
  name: 'appServicePlan'
  scope: commonResourceGroup
  params: {
    appServicePlanName: appServicePlanNaming!.outputs.name
    location: location
    tags: commonTags
    skuName: appServicePlanSku
    kind: appServicePlanKind
  }
}

// ============================================================================
// Network Resources
// ============================================================================

// Public IP for NAT Gateway
module publicIp '../modules/publicIp.bicep' = if (deployNatGateway) {
  name: 'publicIp'
  scope: commonResourceGroup
  params: {
    publicIpName: publicIpNaming!.outputs.name
    location: location
    tags: commonTags
    skuName: 'Standard'
    allocationMethod: 'Static'
  }
}

// NAT Gateway
module natGateway '../modules/natGateway.bicep' = if (deployNatGateway) {
  name: 'natGateway'
  scope: commonResourceGroup
  params: {
    natGatewayName: natGatewayNaming!.outputs.name
    location: location
    tags: commonTags
    publicIpAddressIds: deployNatGateway ? [publicIp!.outputs.id] : []
    idleTimeoutInMinutes: natGatewayIdleTimeoutInMinutes
  }
}

// Virtual Network with Subnets
module virtualNetwork '../modules/virtualNetwork.bicep' = if (deployVirtualNetwork) {
  name: 'virtualNetwork'
  scope: commonResourceGroup
  params: {
    virtualNetworkName: virtualNetworkNaming!.outputs.name
    location: location
    tags: commonTags
    addressPrefixes: vnetAddressPrefixes
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      natGatewayId: deployNatGateway && i == 0 ? natGateway!.outputs.id : '' // Attach NAT Gateway to first subnet
      serviceEndpoints: subnet.name == 'integration-subnet' ? [
        {
          service: 'Microsoft.KeyVault'
          locations: ['*']
        }
        {
          service: 'Microsoft.Storage'
          locations: ['*']
        }
      ] : (subnet.?serviceEndpoints ?? [])
      delegations: subnet.?delegations ?? []
    }]
  }
}

// ============================================================================
// Log Analytics Workspace
// ============================================================================

module logAnalyticsWorkspace '../modules/logAnalyticsWorkspace.bicep' = if (deployLogAnalyticsWorkspace) {
  name: 'logAnalyticsWorkspace'
  scope: commonResourceGroup
  params: {
    workspaceName: logAnalyticsWorkspaceNaming!.outputs.name
    location: location
    tags: commonTags
    skuName: logAnalyticsWorkspaceSku
    retentionInDays: logAnalyticsRetentionInDays
    dailyQuotaGb: logAnalyticsDailyQuotaGb
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// Service Bus Namespace
// ============================================================================

module serviceBus '../modules/serviceBus.bicep' = if (deployServiceBus) {
  name: 'serviceBus'
  scope: commonResourceGroup
  params: {
    serviceBusName: replace(serviceBusNaming!.outputs.name, '-', '')
    location: location
    tags: commonTags
    skuName: serviceBusSku
    capacity: serviceBusCapacity
    queues: []
    topics: []
    enableDiagnostics: enableDiagnostics
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Application Insights and Monitoring
// ============================================================================

module applicationInsights '../modules/applicationInsights.bicep' = if (deployApplicationInsights) {
  name: 'applicationInsights'
  scope: commonResourceGroup
  params: {
    name: applicationInsightsNaming!.outputs.name
    location: location
    tags: commonTags
    applicationType: 'web'
    retentionInDays: applicationInsightsRetentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    workspaceResourceId: enableDiagnostics ? logAnalyticsWorkspaceId : ''
  }
}

// Action Group for email alerts
module actionGroup '../modules/actionGroup.bicep' = if (deployApplicationInsights && length(alertEmailReceivers) > 0) {
  name: 'actionGroup'
  scope: commonResourceGroup
  params: {
    name: actionGroupNaming!.outputs.name
    location: 'global'
    tags: commonTags
    groupShortName: take('${prefix}-${environment}', 12)
    enabled: true
    emailReceivers: alertEmailReceivers
  }
}

// Sample metric alert for Application Insights availability
module availabilityAlert '../modules/metricAlert.bicep' = if (deployApplicationInsights && enableDefaultAlerts && length(alertEmailReceivers) > 0) {
  name: 'availabilityAlert'
  scope: commonResourceGroup
  params: {
    name: '${prefix}-${environment}-availability-alert'
    location: 'global'
    tags: commonTags
    alertDescription: 'Alert when Application Insights availability drops below 99%'
    severity: 1
    enabled: true
    scopes: [applicationInsights!.outputs.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'AvailabilityCheck'
          metricName: 'availabilityResults/availabilityPercentage'
          metricNamespace: 'Microsoft.Insights/components'
          operator: 'LessThan'
          threshold: 99
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actionGroupIds: [actionGroup!.outputs.id]
    autoMitigate: true
  }
}

// Alert for Application Insights exceptions
module exceptionsAlert '../modules/metricAlert.bicep' = if (deployApplicationInsights && enableDefaultAlerts && length(alertEmailReceivers) > 0) {
  name: 'exceptionsAlert'
  scope: commonResourceGroup
  params: {
    name: '${prefix}-${environment}-exceptions-alert'
    location: 'global'
    tags: commonTags
    alertDescription: 'Alert when exception count exceeds threshold'
    severity: 2
    enabled: true
    scopes: [applicationInsights!.outputs.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ExceptionCheck'
          metricName: 'exceptions/count'
          metricNamespace: 'Microsoft.Insights/components'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actionGroupIds: [actionGroup!.outputs.id]
    autoMitigate: true
  }
}

// ============================================================================
// RBAC Role Assignments for Managed Identity
// ============================================================================

// IMPORTANT: The deployment principal (service principal/app registration) must have
// permissions to assign roles. This requires one of the following roles:
// - Owner role at subscription or resource group level
// - User Access Administrator role at subscription or resource group level
// - Custom role with Microsoft.Authorization/roleAssignments/write permission
//
// Note: Contributor role alone is NOT sufficient for assigning RBAC roles!
//
// To grant User Access Administrator role to your service principal:
// az role assignment create --assignee <app-id> --role "User Access Administrator" --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>

// Note: Key Vault now uses Access Policies instead of RBAC
// Access policies are configured directly in the Key Vault module

// Storage Blob Data Contributor role: ba92f5b4-2d11-453d-a403-e96b0029c9fe
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

module storageRoleAssignment '../modules/rbacAssignment.bicep' = if (deployManagedIdentity && deployStorageAccount) {
  name: 'storageRoleAssignment'
  scope: commonResourceGroup
  params: {
    principalId: deployManagedIdentity ? managedIdentity!.outputs.principalId : ''
    roleDefinitionId: storageBlobDataContributorRoleId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Common resource group name')
output resourceGroupName string = commonResourceGroup.name

@description('Common resource group ID')
output resourceGroupId string = commonResourceGroup.id

@description('Key Vault name')
output keyVaultName string = deployKeyVault ? keyVault!.outputs.name : ''

@description('Key Vault ID')
output keyVaultId string = deployKeyVault ? keyVault!.outputs.id : ''

@description('Key Vault URI')
output keyVaultUri string = deployKeyVault ? keyVault!.outputs.uri : ''

@description('Storage Account name')
output storageAccountName string = deployStorageAccount ? storageAccount!.outputs.name : ''

@description('Storage Account ID')
output storageAccountId string = deployStorageAccount ? storageAccount!.outputs.id : ''

@description('App Service Plan name')
output appServicePlanName string = deployAppServicePlan ? appServicePlan!.outputs.name : ''

@description('App Service Plan ID')
output appServicePlanId string = deployAppServicePlan ? appServicePlan!.outputs.id : ''

@description('Managed Identity name')
output managedIdentityName string = deployManagedIdentity ? managedIdentity!.outputs.name : ''

@description('Managed Identity ID')
output managedIdentityId string = deployManagedIdentity ? managedIdentity!.outputs.id : ''

@description('Managed Identity Principal ID')
output managedIdentityPrincipalId string = deployManagedIdentity ? managedIdentity!.outputs.principalId : ''

@description('Managed Identity Client ID')
output managedIdentityClientId string = deployManagedIdentity ? managedIdentity!.outputs.clientId : ''

@description('Virtual Network name')
output virtualNetworkName string = deployVirtualNetwork ? virtualNetwork!.outputs.name : ''

@description('Virtual Network ID')
output virtualNetworkId string = deployVirtualNetwork ? virtualNetwork!.outputs.id : ''

@description('Subnet IDs')
output subnetIds array = deployVirtualNetwork ? virtualNetwork!.outputs.subnetIds : []

@description('Subnet names')
output subnetNames array = deployVirtualNetwork ? virtualNetwork!.outputs.subnetNames : []

@description('NAT Gateway name')
output natGatewayName string = deployNatGateway ? natGateway!.outputs.name : ''

@description('NAT Gateway ID')
output natGatewayId string = deployNatGateway ? natGateway!.outputs.id : ''

@description('Public IP name')
output publicIpName string = deployNatGateway ? publicIp!.outputs.name : ''

@description('Public IP address')
output publicIpAddress string = deployNatGateway ? publicIp!.outputs.ipAddress : ''

@description('Application Insights name')
output applicationInsightsName string = deployApplicationInsights ? applicationInsights!.outputs.name : ''

@description('Application Insights ID')
output applicationInsightsId string = deployApplicationInsights ? applicationInsights!.outputs.id : ''

@description('Application Insights instrumentation key')
output applicationInsightsInstrumentationKey string = deployApplicationInsights ? applicationInsights!.outputs.instrumentationKey : ''

@description('Application Insights connection string')
output applicationInsightsConnectionString string = deployApplicationInsights ? applicationInsights!.outputs.connectionString : ''

@description('Action Group name')
output actionGroupName string = (deployApplicationInsights && length(alertEmailReceivers) > 0) ? actionGroup!.outputs.name : ''

@description('Action Group ID')
output actionGroupId string = (deployApplicationInsights && length(alertEmailReceivers) > 0) ? actionGroup!.outputs.id : ''

@description('Log Analytics Workspace name')
output logAnalyticsWorkspaceName string = deployLogAnalyticsWorkspace ? logAnalyticsWorkspace!.outputs.name : ''

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = deployLogAnalyticsWorkspace ? logAnalyticsWorkspace!.outputs.id : ''

@description('Log Analytics Workspace customer ID')
output logAnalyticsCustomerId string = deployLogAnalyticsWorkspace ? logAnalyticsWorkspace!.outputs.customerId : ''

@description('Service Bus Namespace name')
output serviceBusName string = deployServiceBus ? serviceBus!.outputs.name : ''

@description('Service Bus Namespace ID')
output serviceBusId string = deployServiceBus ? serviceBus!.outputs.id : ''

@description('Service Bus Namespace endpoint')
output serviceBusEndpoint string = deployServiceBus ? serviceBus!.outputs.endpoint : ''

@description('Storage Tables API Connection name')
output storageTablesApiConnectionName string = (deployApiConnections && deployStorageAccount) ? storageTablesApiConnection!.outputs.name : ''

@description('Storage Tables API Connection ID')
output storageTablesApiConnectionId string = (deployApiConnections && deployStorageAccount) ? storageTablesApiConnection!.outputs.id : ''

@description('Storage Tables API Connection status')
output storageTablesApiConnectionStatus string = (deployApiConnections && deployStorageAccount) ? storageTablesApiConnection!.outputs.statusLink : ''
