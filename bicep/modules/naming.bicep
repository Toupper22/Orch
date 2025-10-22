// Naming Convention Module
// This module generates consistent resource names following Azure best practices

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

@description('Azure region short code (e.g., weu for West Europe)')
param locationShort string

@description('Optional workload or integration name')
param workloadName string = ''

@description('Resource type abbreviation')
param resourceType string

@description('Optional instance number for multiple instances')
param instance string = ''

@description('Use short naming format (for resources with strict character limits like storage accounts)')
param useShortNames bool = false

// Naming separator
var separator = '-'

// Short name mappings for environments
var environmentShortNames = {
  dev: 'd'
  test: 't'
  uat: 'u'
  prod: 'p'
}

// Short name mappings for locations
var locationShortNames = {
  weu: 'we'
  eus: 'eu'
  sdc: 'sc'
  westeurope: 'we'
  eastus: 'eu'
  swedencentral: 'sc'
  northeurope: 'ne'
  westus: 'wu'
  centralus: 'cu'
}

// Short name mappings for resource types
var resourceTypeShortNames = {
  st: 'st'
  kv: 'kv'
  func: 'fn'
  logic: 'la'
  sb: 'sb'
  appi: 'ai'
  plan: 'pl'
  vnet: 'vn'
  id: 'id'
}

// Build the base name components
var nameComponents = useShortNames ? [
  take(prefix, 6) // Limit prefix to 6 chars for short names
  environmentShortNames[environment]
  locationShortNames[?locationShort] ?? take(locationShort, 2)
] : [
  prefix
  environment
  locationShort
]

// Add workload name if provided
var workloadShortName = useShortNames && !empty(workloadName) ? take(workloadName, 8) : workloadName
var nameWithWorkload = !empty(workloadName) ? concat(nameComponents, [workloadShortName]) : nameComponents

// Add resource type
var resourceTypeShort = useShortNames ? (resourceTypeShortNames[?resourceType] ?? resourceType) : resourceType
var nameWithType = concat(nameWithWorkload, [resourceTypeShort])

// Add instance if provided
var instanceShort = useShortNames && !empty(instance) ? take(instance, 2) : instance
var finalComponents = !empty(instance) ? concat(nameWithType, [instanceShort]) : nameWithType

// Generate the final name
var resourceName = useShortNames ? toLower(replace(join(finalComponents, ''), '-', '')) : join(finalComponents, separator)

// Output the generated name
output name string = resourceName

// Output individual components for flexibility
output components object = {
  prefix: prefix
  environment: environment
  locationShort: locationShort
  workloadName: workloadName
  resourceType: resourceType
  instance: instance
}

// Common Azure resource type abbreviations
// Reference: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

/*
Resource Type Abbreviations (examples):
- rg: Resource Group
- kv: Key Vault
- st: Storage Account
- plan: App Service Plan
- func: Function App
- logic: Logic App
- sb: Service Bus Namespace
- sbq: Service Bus Queue
- sbt: Service Bus Topic
- id: Managed Identity
- appi: Application Insights
- law: Log Analytics Workspace
- vnet: Virtual Network
- snet: Subnet
- nsg: Network Security Group
- pip: Public IP Address
- nic: Network Interface
- vm: Virtual Machine
*/
