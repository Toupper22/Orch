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

// Naming separator
var separator = '-'

// Build the base name components
var nameComponents = [
  prefix
  environment
  locationShort
]

// Add workload name if provided
var nameWithWorkload = !empty(workloadName) ? concat(nameComponents, [workloadName]) : nameComponents

// Add resource type
var nameWithType = concat(nameWithWorkload, [resourceType])

// Add instance if provided
var finalComponents = !empty(instance) ? concat(nameWithType, [instance]) : nameWithType

// Generate the final name
var resourceName = join(finalComponents, separator)

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
