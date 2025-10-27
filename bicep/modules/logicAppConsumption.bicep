// Logic App Consumption Module
// Deploys an Azure Logic App (Consumption tier) with workflow definition

@description('Name of the Logic App')
param logicAppName string

@description('Azure region for the Logic App')
param location string

@description('Tags to apply to the Logic App')
param tags object = {}

@description('Workflow definition JSON')
param workflowDefinition object

@description('Workflow parameters')
param workflowParameters object = {}

@description('API connections for the workflow')
param connections object = {}

@description('Managed Identity resource ID (optional)')
param managedIdentityId string = ''

@description('Enable or disable the Logic App')
param state string = 'Enabled'

@description('Enable IP-based access restrictions for run history (contents). Triggers will use "Only other Logic Apps" mode.')
param enableContentIpRestrictions bool = true

@description('Array of allowed caller IP addresses (CIDR notation) for viewing run history - configured centrally in config/settings.json')
param allowedCallerIpAddresses array

// Variables
var ipAddressRanges = [for ip in allowedCallerIpAddresses: {
  addressRange: ip
}]

// Deploy Logic App (Consumption)
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  identity: !empty(managedIdentityId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  } : {
    type: 'SystemAssigned'
  }
  properties: {
    state: state
    definition: workflowDefinition
    parameters: !empty(connections) ? union(workflowParameters, {
      '$connections': {
        value: connections
      }
    }) : workflowParameters
    accessControl: enableContentIpRestrictions ? {
      contents: {
        allowedCallerIpAddresses: ipAddressRanges
      }
    } : null
  }
}

// Outputs
@description('Logic App resource ID')
output id string = logicApp.id

@description('Logic App name')
output name string = logicApp.name

@description('Logic App principal ID')
output principalId string = !empty(managedIdentityId) ? '' : logicApp.identity.principalId

@description('Logic App callback URL for manual/request triggers')
#disable-next-line outputs-should-not-contain-secrets
output callbackUrl string = listCallbackUrl('${logicApp.id}/triggers/manual', '2019-05-01').value
