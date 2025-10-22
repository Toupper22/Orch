@description('The name of the action group')
param name string

@description('The location where the resource will be deployed')
param location string = 'global'

@description('Tags to apply to the resource')
param tags object = {}

@description('The short name for the action group (max 12 characters)')
@maxLength(12)
param groupShortName string

@description('Whether the action group is enabled')
param enabled bool = true

@description('Email receivers configuration')
param emailReceivers array = []

@description('SMS receivers configuration')
param smsReceivers array = []

@description('Webhook receivers configuration')
param webhookReceivers array = []

@description('Azure Function receivers configuration')
param azureFunctionReceivers array = []

@description('Logic App receivers configuration')
param logicAppReceivers array = []

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    groupShortName: groupShortName
    enabled: enabled
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    webhookReceivers: webhookReceivers
    azureFunctionReceivers: azureFunctionReceivers
    logicAppReceivers: logicAppReceivers
  }
}

@description('The resource ID of the action group')
output id string = actionGroup.id

@description('The name of the action group')
output name string = actionGroup.name
