// NAT Gateway Module
// Deploys an Azure NAT Gateway for outbound internet connectivity

@description('Name of the NAT Gateway')
param natGatewayName string

@description('Azure region for the NAT Gateway')
param location string

@description('Tags to apply to the NAT Gateway')
param tags object = {}

@description('Public IP Address resource IDs to associate with the NAT Gateway')
param publicIpAddressIds array = []

@description('Idle timeout in minutes')
@minValue(4)
@maxValue(120)
param idleTimeoutInMinutes int = 4

@description('Availability zones')
param zones array = []

@description('NAT Gateway SKU')
@allowed([
  'Standard'
])
param skuName string = 'Standard'

// Deploy NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2023-09-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  zones: !empty(zones) ? zones : null
  properties: {
    idleTimeoutInMinutes: idleTimeoutInMinutes
    publicIpAddresses: [for ipId in publicIpAddressIds: {
      id: ipId
    }]
  }
}

// Outputs
@description('NAT Gateway resource ID')
output id string = natGateway.id

@description('NAT Gateway name')
output name string = natGateway.name

@description('NAT Gateway object')
output natGateway object = natGateway
