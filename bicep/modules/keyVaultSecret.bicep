// Key Vault Secret Module
// Creates a secret in an existing Key Vault

@description('Name of the existing Key Vault')
param keyVaultName string

@description('Name of the secret')
param secretName string

@description('Value of the secret')
@secure()
param secretValue string

@description('Tags to apply to the secret')
param tags object = {}

// Reference to existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Create the secret
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  tags: tags
  properties: {
    value: secretValue
  }
}

// Outputs
@description('Secret resource ID')
output id string = secret.id

@description('Secret name')
output name string = secret.name

@description('Secret URI')
output uri string = secret.properties.secretUri
