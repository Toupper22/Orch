// Virtual Network Module
// Deploys an Azure Virtual Network with subnets

@description('Name of the Virtual Network')
param virtualNetworkName string

@description('Azure region for the Virtual Network')
param location string

@description('Tags to apply to the Virtual Network')
param tags object = {}

@description('Virtual Network address prefixes')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Subnets to create')
param subnets array = []

@description('Enable DDoS protection')
param enableDdosProtection bool = false

@description('DDoS protection plan ID (required if enableDdosProtection is true)')
param ddosProtectionPlanId string = ''

@description('Enable VM protection')
param enableVmProtection bool = false

// Deploy Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection && !empty(ddosProtectionPlanId) ? {
      id: ddosProtectionPlanId
    } : null
    enableVmProtection: enableVmProtection
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') && !empty(subnet.networkSecurityGroupId) ? {
          id: subnet.networkSecurityGroupId
        } : null
        routeTable: contains(subnet, 'routeTableId') && !empty(subnet.routeTableId) ? {
          id: subnet.routeTableId
        } : null
        natGateway: contains(subnet, 'natGatewayId') && !empty(subnet.natGatewayId) ? {
          id: subnet.natGatewayId
        } : null
        serviceEndpoints: subnet.?serviceEndpoints ?? []
        delegations: subnet.?delegations ?? []
        privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies ?? 'Disabled'
        privateLinkServiceNetworkPolicies: subnet.?privateLinkServiceNetworkPolicies ?? 'Enabled'
      }
    }]
  }
}

// Outputs
@description('Virtual Network resource ID')
output id string = virtualNetwork.id

@description('Virtual Network name')
output name string = virtualNetwork.name

@description('Subnet resource IDs')
output subnetIds array = [for (subnet, i) in subnets: virtualNetwork.properties.subnets[i].id]

@description('Subnet names')
output subnetNames array = [for (subnet, i) in subnets: virtualNetwork.properties.subnets[i].name]

@description('Virtual Network object')
output virtualNetwork object = virtualNetwork
