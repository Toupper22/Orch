// Managed Identity Module
// Deploys a User-Assigned Managed Identity for shared access across resources

@description('Name of the Managed Identity')
param managedIdentityName string

@description('Azure region for the Managed Identity')
param location string

@description('Tags to apply to the Managed Identity')
param tags object = {}

@description('Key Vault resource ID for role assignment')
param keyVaultId string = ''

@description('Storage Account resource ID for role assignment')
param storageAccountId string = ''

@description('Assign Key Vault Secrets User role')
param assignKeyVaultSecretsUser bool = true

@description('Assign Storage Blob Data Contributor role')
param assignStorageBlobDataContributor bool = true

// Deploy User-Assigned Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}

// Built-in role definition IDs
// Key Vault Secrets User: 4633458b-17de-408a-b874-0445c86b69e6
var keyVaultSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

// Storage Blob Data Contributor: ba92f5b4-2d11-453d-a403-e96b0029c9fe
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// Assign Key Vault Secrets User role to the Managed Identity
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(keyVaultId) && assignKeyVaultSecretsUser) {
  name: guid(managedIdentity.id, keyVaultId, keyVaultSecretsUserRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Assign Storage Blob Data Contributor role to the Managed Identity
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(storageAccountId) && assignStorageBlobDataContributor) {
  name: guid(managedIdentity.id, storageAccountId, storageBlobDataContributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
@description('Managed Identity resource ID')
output id string = managedIdentity.id

@description('Managed Identity name')
output name string = managedIdentity.name

@description('Managed Identity principal ID')
output principalId string = managedIdentity.properties.principalId

@description('Managed Identity client ID')
output clientId string = managedIdentity.properties.clientId

@description('Managed Identity object')
output managedIdentity object = managedIdentity
