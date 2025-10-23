@description('The name of the API Management service instance')
param sharedApimName string
param publicIpName string

@description('The email address of the owner of the service')
@minLength(1)

param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

//@secure()
//param appi_key string

param sharedKeyvaultName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])

param skuName string

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int

@description('Location for all resources.')
param location string = resourceGroup().location

/* 
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
} */

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: sharedApimName
  location: location
  sku: {
    name: skuName
    capacity: skuCount
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    //publicIpAddressId: publicIp.id
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${sharedApimName}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
    }
    virtualNetworkType: skuName == 'Premium' ? 'External' : 'None'
    disableGateway: false
    natGatewayState: 'Disabled'
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
    legacyPortalStatus: 'Enabled'
    developerPortalStatus: 'Enabled'
  }
}

/*resource aiLoggerWithSystemAssignedIdentity 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  name: 'appi-luv-shared-${tier}'
  parent: apiManagementService
  properties: {
    loggerType: 'applicationInsights'
    description: 'Application Insights logger with system-assigned managed identity'
    credentials: {
       instrumentationKey: appi_key
    }
    isBuffered: true
    resourceId: appi_luv_shared_externalid
  }
} */

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${sharedKeyvaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: apiManagementService.identity.tenantId
        objectId: apiManagementService.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
