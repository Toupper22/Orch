// Public IP Address Module
// Deploys a Public IP Address for NAT Gateway or other resources

@description('Name of the Public IP Address')
param publicIpName string

@description('Azure region for the Public IP Address')
param location string

@description('Tags to apply to the Public IP Address')
param tags object = {}

@description('Public IP Address SKU')
@allowed([
  'Basic'
  'Standard'
])
param skuName string = 'Standard'

@description('Public IP Address allocation method')
@allowed([
  'Static'
  'Dynamic'
])
param allocationMethod string = 'Static'

@description('Public IP Address tier')
@allowed([
  'Regional'
  'Global'
])
param tier string = 'Regional'

@description('Idle timeout in minutes')
@minValue(4)
@maxValue(30)
param idleTimeoutInMinutes int = 4

@description('DNS domain name label (optional)')
param domainNameLabel string = ''

@description('Availability zones')
param zones array = []

// Deploy Public IP Address
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: tier
  }
  zones: !empty(zones) ? zones : null
  properties: {
    publicIPAllocationMethod: allocationMethod
    idleTimeoutInMinutes: idleTimeoutInMinutes
    dnsSettings: !empty(domainNameLabel) ? {
      domainNameLabel: domainNameLabel
    } : null
  }
}

// Outputs
@description('Public IP Address resource ID')
output id string = publicIp.id

@description('Public IP Address name')
output name string = publicIp.name

@description('Public IP Address')
output ipAddress string = publicIp.properties.?ipAddress ?? ''

@description('Public IP Address object')
output publicIp object = publicIp
