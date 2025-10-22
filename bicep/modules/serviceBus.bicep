// Service Bus Module
// Deploys Azure Service Bus Namespace with queues and topics

@description('Name of the Service Bus Namespace')
param serviceBusName string

@description('Azure region for the Service Bus')
param location string

@description('Tags to apply to the Service Bus')
param tags object = {}

@description('Service Bus SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Service Bus capacity (only for Premium SKU, 1-16 messaging units)')
@allowed([
  1
  2
  4
  8
  16
])
param capacity int = 1

@description('Queues to create')
param queues array = []

@description('Topics to create')
param topics array = []

@description('Enable diagnostic settings')
param enableDiagnostics bool = false

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

// Deploy Service Bus Namespace
resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
    capacity: skuName == 'Premium' ? capacity : null
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: skuName == 'Premium' ? true : false
  }
}

// Create queues
resource serviceBusQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for queue in queues: {
  name: queue.name
  parent: serviceBus
  properties: {
    lockDuration: queue.?lockDuration ?? 'PT1M'
    maxSizeInMegabytes: queue.?maxSizeInMegabytes ?? 1024
    requiresDuplicateDetection: queue.?requiresDuplicateDetection ?? false
    requiresSession: queue.?requiresSession ?? false
    defaultMessageTimeToLive: queue.?defaultMessageTimeToLive ?? 'P14D'
    deadLetteringOnMessageExpiration: queue.?deadLetteringOnMessageExpiration ?? false
    maxDeliveryCount: queue.?maxDeliveryCount ?? 10
    enableBatchedOperations: queue.?enableBatchedOperations ?? true
    enablePartitioning: queue.?enablePartitioning ?? false
  }
}]

// Create topics
resource serviceBusTopics 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = [for topic in topics: {
  name: topic.name
  parent: serviceBus
  properties: {
    maxSizeInMegabytes: topic.?maxSizeInMegabytes ?? 1024
    requiresDuplicateDetection: topic.?requiresDuplicateDetection ?? false
    defaultMessageTimeToLive: topic.?defaultMessageTimeToLive ?? 'P14D'
    enableBatchedOperations: topic.?enableBatchedOperations ?? true
    enablePartitioning: topic.?enablePartitioning ?? false
  }
}]

// Create subscriptions for topics
resource serviceBusSubscriptions 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = [for topic in topics: if (contains(topic, 'subscriptions')) {
  name: topic.subscriptions[0].name
  parent: serviceBusTopics[indexOf(topics, topic)]
  properties: {
    lockDuration: topic.subscriptions[0].?lockDuration ?? 'PT1M'
    requiresSession: topic.subscriptions[0].?requiresSession ?? false
    defaultMessageTimeToLive: topic.subscriptions[0].?defaultMessageTimeToLive ?? 'P14D'
    deadLetteringOnMessageExpiration: topic.subscriptions[0].?deadLetteringOnMessageExpiration ?? false
    maxDeliveryCount: topic.subscriptions[0].?maxDeliveryCount ?? 10
  }
}]

// Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  name: '${serviceBusName}-diagnostics'
  scope: serviceBus
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
@description('Service Bus Namespace resource ID')
output id string = serviceBus.id

@description('Service Bus Namespace name')
output name string = serviceBus.name

@description('Service Bus Namespace endpoint')
output endpoint string = serviceBus.properties.serviceBusEndpoint

@description('Queue names')
output queueNames array = [for (queue, i) in queues: serviceBusQueues[i].name]

@description('Topic names')
output topicNames array = [for (topic, i) in topics: serviceBusTopics[i].name]

@description('Service Bus object')
output serviceBus object = serviceBus
