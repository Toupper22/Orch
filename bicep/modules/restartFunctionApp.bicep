// Restart Function App Module
// Uses a deployment script to restart a Function App after infrastructure changes

@description('Name of the Function App to restart')
param functionAppName string

@description('Azure region for the deployment script')
param location string

@description('Managed Identity resource ID with permissions to restart the Function App')
param managedIdentityId string

// Deployment Script to restart Function App
resource restartScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'restart-${functionAppName}'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.50.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    scriptContent: 'az functionapp restart --name ${functionAppName} --resource-group ${resourceGroup().name} && echo "Function App ${functionAppName} restarted successfully"'
  }
}

// Outputs
@description('Deployment script resource ID')
output id string = restartScript.id

@description('Deployment script name')
output name string = restartScript.name
