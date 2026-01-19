# Development Specification: Secure Function App Communication

## Document Information

| Field | Value |
|-------|-------|
| **Version** | 1.1.0 |
| **Status** | Draft |
| **Created** | 2026-01-19 |
| **Author** | Architecture Team |
| **Branch** | cursor/function-app-secure-communication-a57d |

---

## Table of Contents

1. [Overview](#1-overview)
2. [Requirements](#2-requirements)
3. [Architecture Design](#3-architecture-design)
4. [Network Security](#4-network-security)
5. [Identity and Access Management](#5-identity-and-access-management)
6. [Storage Account Security](#6-storage-account-security)
7. [Key Vault Security](#7-key-vault-security)
8. [Function App Configuration](#8-function-app-configuration)
9. [Remote Client Access Patterns](#9-remote-client-access-patterns)
10. [Bicep Module Changes](#10-bicep-module-changes)
11. [Implementation Plan](#11-implementation-plan)
12. [Testing and Validation](#12-testing-and-validation)
13. [Monitoring and Diagnostics](#13-monitoring-and-diagnostics)
14. [Rollback Strategy](#14-rollback-strategy)
15. [Security Checklist](#15-security-checklist)

---

## 1. Overview

### 1.1 Purpose

This specification defines the architecture and implementation details for an Azure Function App that securely communicates with Storage Accounts and Key Vault resources that are protected by firewalls and connected to a Virtual Network (VNet).

### 1.2 Scope

The scope covers:
- Function App VNet integration
- Private endpoint configuration for Storage Accounts
- Private endpoint configuration for Key Vault
- DNS configuration for private endpoints
- Managed identity-based authentication
- Network security rules and firewall configurations

### 1.3 Current State

The existing infrastructure already supports:
- ✅ VNet with dedicated subnets (integration-subnet, private-endpoint-subnet)
- ✅ NAT Gateway for outbound connectivity
- ✅ Service endpoints for Microsoft.Storage and Microsoft.KeyVault
- ✅ Managed identity authentication
- ✅ Storage account firewall with `Deny` default action
- ✅ Key Vault firewall with Azure Services bypass

### 1.4 Target State

Enhance security by implementing:
- 🎯 Private endpoints for Storage Accounts (blob, file, queue, table)
- 🎯 Private endpoints for Key Vault
- 🎯 Private DNS zones for name resolution
- 🎯 Removal of public network access where possible
- 🎯 Zero-trust network architecture

---

## 2. Requirements

### 2.1 Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Function App must connect to Storage Accounts via private network | High |
| FR-02 | Function App must connect to Key Vault via private network | High |
| FR-03 | All data in transit must be encrypted (TLS 1.2+) | High |
| FR-04 | Function App must use Managed Identity for authentication | High |
| FR-05 | Storage Accounts must deny public network access | Medium |
| FR-06 | Key Vault must deny public network access | Medium |
| FR-07 | Solution must work across all environments (dev, test, uat, prod) | High |

### 2.2 Non-Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-01 | Deployment must be idempotent | High |
| NFR-02 | Solution must not impact existing integrations | High |
| NFR-03 | DNS resolution must be < 100ms | Medium |
| NFR-04 | Private endpoint creation must complete within 10 minutes | Medium |
| NFR-05 | Solution must support hybrid connectivity (on-premises) | Low |

### 2.3 Security Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| SR-01 | No storage account keys in application settings | High |
| SR-02 | All network traffic must stay within Azure backbone | High |
| SR-03 | Service endpoints must be replaced with private endpoints | Medium |
| SR-04 | Network Security Groups must restrict traffic | Medium |
| SR-05 | Diagnostic logs must capture all access attempts | High |

---

## 3. Architecture Design

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Azure Subscription                                   │
│                                                                                   │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                        Virtual Network (10.0.0.0/16)                      │   │
│  │                                                                            │   │
│  │  ┌─────────────────────────────┐  ┌──────────────────────────────────┐   │   │
│  │  │   Integration Subnet        │  │   Private Endpoint Subnet         │   │   │
│  │  │   (10.0.1.0/24)             │  │   (10.0.2.0/24)                   │   │   │
│  │  │                             │  │                                    │   │   │
│  │  │  ┌─────────────────────┐   │  │  ┌────────────────────────────┐   │   │   │
│  │  │  │                     │   │  │  │ Private Endpoints          │   │   │   │
│  │  │  │   Function App      │   │  │  │                            │   │   │   │
│  │  │  │   (VNet Integrated) │───┼──┼──│ • Storage (blob, file,     │   │   │   │
│  │  │  │                     │   │  │  │   queue, table)            │   │   │   │
│  │  │  │   • Managed ID      │   │  │  │ • Key Vault                │   │   │   │
│  │  │  │   • HTTPS Only      │   │  │  │                            │   │   │   │
│  │  │  │                     │   │  │  └────────────────────────────┘   │   │   │
│  │  │  └─────────────────────┘   │  │                                    │   │   │
│  │  │                             │  │                                    │   │   │
│  │  │  ┌─────────────────────┐   │  │                                    │   │   │
│  │  │  │    NAT Gateway      │   │  │                                    │   │   │
│  │  │  │    (Outbound)       │   │  │                                    │   │   │
│  │  │  └─────────────────────┘   │  │                                    │   │   │
│  │  └─────────────────────────────┘  └──────────────────────────────────────┘   │
│  │                                                                            │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                   │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                        Private DNS Zones                                  │   │
│  │                                                                            │   │
│  │  • privatelink.blob.core.windows.net                                      │   │
│  │  • privatelink.file.core.windows.net                                      │   │
│  │  • privatelink.queue.core.windows.net                                     │   │
│  │  • privatelink.table.core.windows.net                                     │   │
│  │  • privatelink.vaultcore.azure.net                                        │   │
│  │                                                                            │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                   │
│  ┌────────────────────────┐  ┌────────────────────────┐                         │
│  │    Storage Account     │  │      Key Vault         │                         │
│  │                        │  │                        │                         │
│  │  • Public Access: OFF  │  │  • Public Access: OFF  │                         │
│  │  • Private EP: ON      │  │  • Private EP: ON      │                         │
│  │  • Firewall: Deny      │  │  • Firewall: Deny      │                         │
│  │                        │  │                        │                         │
│  └────────────────────────┘  └────────────────────────┘                         │
│                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Network Flow

```
Function App → VNet Integration → Private Endpoint → Storage Account / Key Vault
     ↓
     ↓ (DNS Resolution)
     ↓
Private DNS Zone → Private Endpoint IP (10.0.2.x)
     ↓
     ↓ (Traffic over Azure backbone)
     ↓
Storage Account / Key Vault (No public internet exposure)
```

### 3.3 Component Inventory

| Component | Purpose | Subnet | Private Endpoint |
|-----------|---------|--------|------------------|
| Function App | Compute/Processing | integration-subnet | N/A (VNet integration) |
| Function Storage | Function runtime | N/A | Yes (blob, file, queue, table) |
| Integration Storage | Data storage | N/A | Yes (blob, table) |
| Key Vault (Common) | Shared secrets | N/A | Yes |
| Key Vault (Integration) | Integration secrets | N/A | Yes |

---

## 4. Network Security

### 4.1 Subnet Configuration

#### Integration Subnet

```bicep
{
  name: 'integration-subnet'
  addressPrefix: '10.0.1.0/24'
  delegations: [
    {
      name: 'Microsoft.Web.serverFarms'
      properties: {
        serviceName: 'Microsoft.Web/serverFarms'
      }
    }
  ]
  serviceEndpoints: [] // Remove service endpoints when using private endpoints
  natGatewayId: natGateway.id
}
```

#### Private Endpoint Subnet

```bicep
{
  name: 'private-endpoint-subnet'
  addressPrefix: '10.0.2.0/24'
  privateEndpointNetworkPolicies: 'Disabled'  // Required for private endpoints
  privateLinkServiceNetworkPolicies: 'Enabled'
}
```

### 4.2 Network Security Group (NSG) Rules

#### Integration Subnet NSG

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowHTTPS | Outbound | VNet | Storage | 443 | Allow |
| 110 | AllowKeyVault | Outbound | VNet | KeyVault | 443 | Allow |
| 120 | AllowServiceBus | Outbound | VNet | ServiceBus | 443 | Allow |
| 130 | AllowAzureMonitor | Outbound | VNet | AzureMonitor | 443 | Allow |
| 200 | DenyAllOutbound | Outbound | * | * | * | Deny |

#### Private Endpoint Subnet NSG

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowVNetInbound | Inbound | VNet | VNet | 443 | Allow |
| 200 | DenyAllInbound | Inbound | * | * | * | Deny |

### 4.3 DNS Configuration

Private DNS zones must be linked to the VNet for proper name resolution:

| Resource Type | Private DNS Zone | Example FQDN |
|---------------|------------------|--------------|
| Storage (Blob) | privatelink.blob.core.windows.net | staccount.blob.core.windows.net |
| Storage (File) | privatelink.file.core.windows.net | staccount.file.core.windows.net |
| Storage (Queue) | privatelink.queue.core.windows.net | staccount.queue.core.windows.net |
| Storage (Table) | privatelink.table.core.windows.net | staccount.table.core.windows.net |
| Key Vault | privatelink.vaultcore.azure.net | keyvault.vault.azure.net |

---

## 5. Identity and Access Management

### 5.1 Managed Identity Permissions

The Function App uses a User-Assigned Managed Identity with the following RBAC roles:

| Resource | Role | Role ID | Purpose |
|----------|------|---------|---------|
| Storage Account (Blob) | Storage Blob Data Contributor | ba92f5b4-2d11-453d-a403-e96b0029c9fe | Read/write blob data |
| Storage Account (Table) | Storage Table Data Contributor | 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3 | Read/write table data |
| Storage Account (Queue) | Storage Queue Data Contributor | 974c5e8b-45b9-4653-ba55-5f855dd0fb88 | Read/write queue messages |
| Key Vault | Key Vault Secrets User | 4633458b-17de-408a-b874-0445c86b69e6 | Read secrets |
| Service Bus | Azure Service Bus Data Sender | 69a216fc-b8fb-44d8-bc22-1f3c2cd27a39 | Send messages |
| Service Bus | Azure Service Bus Data Receiver | 4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0 | Receive messages |

### 5.2 Key Vault Access Configuration

When using private endpoints, Key Vault should use RBAC authorization instead of access policies:

```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  properties: {
    enableRbacAuthorization: true  // Use RBAC instead of access policies
    publicNetworkAccess: 'Disabled'  // Disable public access
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'  // No bypass when using private endpoints
    }
  }
}
```

---

## 6. Storage Account Security

### 6.1 Network Rules Configuration

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  properties: {
    publicNetworkAccess: 'Disabled'  // Disable all public access
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'  // No bypass when using private endpoints
      ipRules: []  // No IP rules needed
      virtualNetworkRules: []  // No VNet rules needed (using private endpoints)
    }
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}
```

### 6.2 Private Endpoints for Storage

Each storage service (blob, file, queue, table) requires a separate private endpoint:

| Sub-Resource | Private Endpoint Name | DNS Zone |
|--------------|----------------------|----------|
| blob | {storage}-blob-pe | privatelink.blob.core.windows.net |
| file | {storage}-file-pe | privatelink.file.core.windows.net |
| queue | {storage}-queue-pe | privatelink.queue.core.windows.net |
| table | {storage}-table-pe | privatelink.table.core.windows.net |

### 6.3 Function App Storage Configuration

For the Function App runtime storage, use identity-based connections:

```bicep
appSettings: [
  {
    name: 'AzureWebJobsStorage__accountName'
    value: storageAccountName
  }
  {
    name: 'AzureWebJobsStorage__credential'
    value: 'managedidentity'
  }
  {
    name: 'AzureWebJobsStorage__clientId'
    value: managedIdentityClientId  // User-assigned managed identity
  }
  // For file share (required for Consumption/Premium plans)
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/StorageConnectionString/)'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: functionAppName
  }
]
```

---

## 7. Key Vault Security

### 7.1 Network Configuration

```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
      ipRules: []
      virtualNetworkRules: []
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}
```

### 7.2 Private Endpoint Configuration

```bicep
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: '${keyVaultName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}
```

### 7.3 Function App Key Vault References

Use Key Vault references in app settings:

```bicep
appSettings: [
  {
    name: 'MySecret'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}/secrets/MySecret/)'
  }
  {
    name: 'ConnectionString'
    value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=ConnectionString)'
  }
]
```

---

## 8. Function App Configuration

### 8.1 VNet Integration Settings

```bicep
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  properties: {
    virtualNetworkSubnetId: integrationSubnetId
    vnetRouteAllEnabled: true  // Route all traffic through VNet
    vnetContentShareEnabled: true  // Access content share via VNet
    vnetImagePullEnabled: true  // Pull images via VNet (if using containers)
  }
  siteConfig: {
    vnetPrivatePortsCount: 2  // For outbound connections
  }
}
```

### 8.2 Critical App Settings

```bicep
appSettings: [
  // Storage - Identity-based connection
  {
    name: 'AzureWebJobsStorage__accountName'
    value: storageAccountName
  }
  {
    name: 'AzureWebJobsStorage__credential'
    value: 'managedidentity'
  }
  {
    name: 'AzureWebJobsStorage__clientId'
    value: managedIdentityClientId
  }
  // Key Vault URI
  {
    name: 'KeyVaultUri'
    value: keyVaultUri
  }
  // VNet DNS settings
  {
    name: 'WEBSITE_DNS_SERVER'
    value: '168.63.129.16'  // Azure DNS
  }
  {
    name: 'WEBSITE_VNET_ROUTE_ALL'
    value: '1'
  }
]
```

### 8.3 Health Check Configuration

```bicep
siteConfig: {
  healthCheckPath: '/api/health'
  autoHealEnabled: true
  autoHealRules: {
    triggers: {
      statusCodes: [
        {
          status: 500
          subStatus: 0
          win32Status: 0
          count: 5
          timeInterval: '00:05:00'
        }
      ]
    }
    actions: {
      actionType: 'Recycle'
      minProcessExecutionTime: '00:01:00'
    }
  }
}
```

---

## 9. Remote Client Access Patterns

This section describes how external/remote clients can securely call the Function App to read/write files and retrieve secrets.

### 9.1 Architecture Overview

```
                                        ┌─────────────────────────────────────────────────┐
                                        │              Azure Subscription                  │
                                        │                                                  │
┌──────────────────┐                   │  ┌─────────────────────────────────────────────┐│
│  Remote Clients  │                   │  │           Virtual Network                    ││
│                  │                   │  │                                              ││
│  • Web Apps      │    HTTPS/443      │  │  ┌──────────────────────────────────────┐  ││
│  • Mobile Apps   │ ──────────────────┼──┼─▶│  Option A: Public Function App       │  ││
│  • Partner APIs  │                   │  │  │  (with access restrictions)          │  ││
│  • On-Premises   │                   │  │  └──────────────────────────────────────┘  ││
│                  │                   │  │                     │                       ││
└──────────────────┘                   │  │                     │ VNet Integration      ││
        │                              │  │                     ▼                       ││
        │                              │  │  ┌──────────────────────────────────────┐  ││
        │    Option B: API Management  │  │  │     Private Endpoints               │  ││
        └──────────────────────────────┼──┼─▶│  • Storage Account                   │  ││
                                       │  │  │  • Key Vault                         │  ││
        │    Option C: App Gateway     │  │  └──────────────────────────────────────┘  ││
        └──────────────────────────────┼──┤                                              ││
                                       │  └─────────────────────────────────────────────┘│
        │    Option D: VPN/ExpressRoute│                                                  │
        └──────────────────────────────┼──────────────────────────────────────────────────┤
                                       │                                                  │
                                       └──────────────────────────────────────────────────┘
```

### 9.2 Option A: Public Function App with Access Restrictions (Recommended for Most Cases)

The Function App maintains a public endpoint but with strict access restrictions. The Function App uses VNet integration for **outbound** calls to Storage and Key Vault.

#### 9.2.1 Configuration

```bicep
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  properties: {
    publicNetworkAccess: 'Enabled'  // Allow inbound from internet
    virtualNetworkSubnetId: integrationSubnetId  // VNet for outbound
    siteConfig: {
      ipSecurityRestrictions: [
        {
          name: 'AllowSpecificIPs'
          ipAddress: '203.0.113.0/24'  // Your client IP range
          action: 'Allow'
          priority: 100
        }
        {
          name: 'AllowAzureServices'
          ipAddress: 'AzureCloud'
          tag: 'ServiceTag'
          action: 'Allow'
          priority: 200
        }
        {
          name: 'DenyAll'
          ipAddress: 'Any'
          action: 'Deny'
          priority: 2147483647
        }
      ]
      ipSecurityRestrictionsDefaultAction: 'Deny'
    }
  }
}
```

#### 9.2.2 Client Authentication

```csharp
// Client code to call the Function App
using var client = new HttpClient();

// Option 1: Function Key Authentication
client.DefaultRequestHeaders.Add("x-functions-key", "<function-key>");

// Option 2: Azure AD Authentication (Recommended)
var credential = new ClientSecretCredential(tenantId, clientId, clientSecret);
var token = await credential.GetTokenAsync(new TokenRequestContext(
    new[] { "api://<function-app-client-id>/.default" }));
client.DefaultRequestHeaders.Authorization = 
    new AuthenticationHeaderValue("Bearer", token.Token);

// Call the Function App
var response = await client.PostAsync(
    "https://<function-app>.azurewebsites.net/api/files/upload",
    new StringContent(jsonPayload, Encoding.UTF8, "application/json"));
```

#### 9.2.3 Function App API Endpoints

```csharp
// Function to write files to Storage (via private endpoint)
[Function("UploadFile")]
public async Task<HttpResponseData> UploadFile(
    [HttpTrigger(AuthorizationLevel.Function, "post", Route = "files/upload")] 
    HttpRequestData req)
{
    var blobClient = _blobServiceClient.GetBlobContainerClient("uploads")
        .GetBlobClient(fileName);
    
    await blobClient.UploadAsync(fileStream, overwrite: true);
    
    return req.CreateResponse(HttpStatusCode.Created);
}

// Function to read files from Storage (via private endpoint)
[Function("DownloadFile")]
public async Task<HttpResponseData> DownloadFile(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "files/{fileName}")] 
    HttpRequestData req, string fileName)
{
    var blobClient = _blobServiceClient.GetBlobContainerClient("uploads")
        .GetBlobClient(fileName);
    
    var download = await blobClient.DownloadContentAsync();
    
    var response = req.CreateResponse(HttpStatusCode.OK);
    response.Body = download.Value.Content.ToStream();
    return response;
}

// Function to get secrets from Key Vault (via private endpoint)
[Function("GetConfiguration")]
public async Task<HttpResponseData> GetConfiguration(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = "config/{secretName}")] 
    HttpRequestData req, string secretName)
{
    var secret = await _secretClient.GetSecretAsync(secretName);
    
    var response = req.CreateResponse(HttpStatusCode.OK);
    await response.WriteAsJsonAsync(new { value = secret.Value.Value });
    return response;
}
```

### 9.3 Option B: Azure API Management (Enterprise Grade)

For enterprise scenarios requiring advanced features like rate limiting, caching, and API versioning.

#### 9.3.1 Architecture

```
Remote Client → API Management (Public) → Function App (Private) → Storage/KeyVault
```

#### 9.3.2 Configuration

```bicep
resource apiManagement 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apiManagementName
  location: location
  sku: {
    name: 'Developer'  // Use 'Premium' for VNet integration
    capacity: 1
  }
  properties: {
    publisherEmail: 'admin@contoso.com'
    publisherName: 'Contoso'
    virtualNetworkType: 'External'  // or 'Internal' for full private
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
  }
}

// API Definition
resource api 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apiManagement
  name: 'file-api'
  properties: {
    displayName: 'File Management API'
    path: 'files'
    protocols: ['https']
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}
```

#### 9.3.3 APIM Policy for Authentication

```xml
<policies>
  <inbound>
    <base />
    <validate-jwt header-name="Authorization" require-scheme="Bearer">
      <openid-config url="https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration" />
      <required-claims>
        <claim name="aud" match="all">
          <value>api://{api-client-id}</value>
        </claim>
      </required-claims>
    </validate-jwt>
    <set-header name="x-functions-key" exists-action="override">
      <value>{{function-key}}</value>
    </set-header>
    <rate-limit calls="100" renewal-period="60" />
  </inbound>
</policies>
```

### 9.4 Option C: Azure Application Gateway with WAF

For scenarios requiring Web Application Firewall protection.

#### 9.4.1 Architecture

```
Remote Client → Application Gateway (WAF) → Function App (Private Endpoint) → Storage/KeyVault
```

#### 9.4.2 Configuration

```bicep
resource applicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    backendAddressPools: [
      {
        name: 'functionAppPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${functionAppName}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    // ... additional configuration
  }
}
```

### 9.5 Option D: Private Function App with VPN/ExpressRoute

For on-premises clients or full private network scenarios.

#### 9.5.1 Architecture

```
On-Premises Client → VPN Gateway/ExpressRoute → VNet → Function App (Private Endpoint) → Storage/KeyVault
```

#### 9.5.2 Function App Private Endpoint

```bicep
// Make Function App fully private
resource functionAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: '${functionAppName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${functionAppName}-connection'
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: ['sites']
        }
      }
    ]
  }
}

// Disable public access
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  properties: {
    publicNetworkAccess: 'Disabled'
    // ...
  }
}
```

#### 9.5.3 VPN Gateway Configuration

```bicep
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnPublicIp.id
          }
        }
      }
    ]
  }
}
```

### 9.6 Client SDK Examples

#### 9.6.1 C# Client

```csharp
public class SecureFileClient
{
    private readonly HttpClient _httpClient;
    private readonly string _baseUrl;
    private readonly TokenCredential _credential;
    
    public SecureFileClient(string functionAppUrl, TokenCredential credential)
    {
        _baseUrl = functionAppUrl;
        _credential = credential;
        _httpClient = new HttpClient();
    }
    
    private async Task<string> GetAccessTokenAsync()
    {
        var token = await _credential.GetTokenAsync(
            new TokenRequestContext(new[] { "api://<app-id>/.default" }), 
            CancellationToken.None);
        return token.Token;
    }
    
    // Upload a file to Storage via Function App
    public async Task<bool> UploadFileAsync(string fileName, Stream content)
    {
        var token = await GetAccessTokenAsync();
        _httpClient.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        
        using var formContent = new MultipartFormDataContent();
        formContent.Add(new StreamContent(content), "file", fileName);
        
        var response = await _httpClient.PostAsync(
            $"{_baseUrl}/api/files/upload", formContent);
        
        return response.IsSuccessStatusCode;
    }
    
    // Download a file from Storage via Function App
    public async Task<Stream> DownloadFileAsync(string fileName)
    {
        var token = await GetAccessTokenAsync();
        _httpClient.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        
        var response = await _httpClient.GetAsync(
            $"{_baseUrl}/api/files/{fileName}");
        
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStreamAsync();
    }
    
    // Get a secret from Key Vault via Function App
    public async Task<string> GetSecretAsync(string secretName)
    {
        var token = await GetAccessTokenAsync();
        _httpClient.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        
        var response = await _httpClient.GetAsync(
            $"{_baseUrl}/api/config/{secretName}");
        
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<SecretResponse>();
        return result?.Value ?? string.Empty;
    }
}

// Usage
var credential = new ClientSecretCredential(tenantId, clientId, clientSecret);
var client = new SecureFileClient("https://myfunction.azurewebsites.net", credential);

// Upload file
await client.UploadFileAsync("document.pdf", fileStream);

// Download file
var downloadStream = await client.DownloadFileAsync("document.pdf");

// Get secret
var connectionString = await client.GetSecretAsync("DatabaseConnectionString");
```

#### 9.6.2 Python Client

```python
import requests
from azure.identity import ClientSecretCredential

class SecureFileClient:
    def __init__(self, function_app_url: str, tenant_id: str, client_id: str, client_secret: str):
        self.base_url = function_app_url
        self.credential = ClientSecretCredential(
            tenant_id=tenant_id,
            client_id=client_id,
            client_secret=client_secret
        )
        self.scope = f"api://{client_id}/.default"
    
    def _get_headers(self) -> dict:
        token = self.credential.get_token(self.scope)
        return {
            "Authorization": f"Bearer {token.token}",
            "Content-Type": "application/json"
        }
    
    def upload_file(self, file_name: str, content: bytes) -> bool:
        """Upload a file to Storage via Function App"""
        headers = self._get_headers()
        del headers["Content-Type"]  # Let requests set it for multipart
        
        files = {"file": (file_name, content)}
        response = requests.post(
            f"{self.base_url}/api/files/upload",
            headers=headers,
            files=files
        )
        return response.status_code == 201
    
    def download_file(self, file_name: str) -> bytes:
        """Download a file from Storage via Function App"""
        headers = self._get_headers()
        response = requests.get(
            f"{self.base_url}/api/files/{file_name}",
            headers=headers
        )
        response.raise_for_status()
        return response.content
    
    def get_secret(self, secret_name: str) -> str:
        """Get a secret from Key Vault via Function App"""
        headers = self._get_headers()
        response = requests.get(
            f"{self.base_url}/api/config/{secret_name}",
            headers=headers
        )
        response.raise_for_status()
        return response.json().get("value", "")

# Usage
client = SecureFileClient(
    function_app_url="https://myfunction.azurewebsites.net",
    tenant_id="<tenant-id>",
    client_id="<client-id>",
    client_secret="<client-secret>"
)

# Upload file
with open("document.pdf", "rb") as f:
    client.upload_file("document.pdf", f.read())

# Download file
content = client.download_file("document.pdf")

# Get secret
connection_string = client.get_secret("DatabaseConnectionString")
```

#### 9.6.3 PowerShell Client

```powershell
function Get-FunctionAppToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$Scope
    )
    
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = $Scope
    }
    
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $body
    
    return $response.access_token
}

function Upload-FileToFunctionApp {
    param(
        [string]$FunctionAppUrl,
        [string]$Token,
        [string]$FilePath
    )
    
    $fileName = Split-Path $FilePath -Leaf
    $fileContent = [System.IO.File]::ReadAllBytes($FilePath)
    
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    $form = @{
        file = Get-Item -Path $FilePath
    }
    
    Invoke-RestMethod -Method Post `
        -Uri "$FunctionAppUrl/api/files/upload" `
        -Headers $headers `
        -Form $form
}

function Get-SecretFromFunctionApp {
    param(
        [string]$FunctionAppUrl,
        [string]$Token,
        [string]$SecretName
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
    
    $response = Invoke-RestMethod -Method Get `
        -Uri "$FunctionAppUrl/api/config/$SecretName" `
        -Headers $headers
    
    return $response.value
}

# Usage
$token = Get-FunctionAppToken `
    -TenantId "<tenant-id>" `
    -ClientId "<client-id>" `
    -ClientSecret "<client-secret>" `
    -Scope "api://<app-id>/.default"

# Upload file
Upload-FileToFunctionApp `
    -FunctionAppUrl "https://myfunction.azurewebsites.net" `
    -Token $token `
    -FilePath "C:\Documents\report.pdf"

# Get secret
$connectionString = Get-SecretFromFunctionApp `
    -FunctionAppUrl "https://myfunction.azurewebsites.net" `
    -Token $token `
    -SecretName "DatabaseConnectionString"
```

### 9.7 Function App Implementation

Complete Function App implementation for handling client requests:

```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

public class FileManagementFunctions
{
    private readonly ILogger<FileManagementFunctions> _logger;
    private readonly BlobServiceClient _blobServiceClient;
    private readonly SecretClient _secretClient;
    
    public FileManagementFunctions(
        ILogger<FileManagementFunctions> logger,
        BlobServiceClient blobServiceClient,
        SecretClient secretClient)
    {
        _logger = logger;
        _blobServiceClient = blobServiceClient;
        _secretClient = secretClient;
    }
    
    /// <summary>
    /// Upload file to blob storage (Storage behind private endpoint)
    /// POST /api/files/upload
    /// </summary>
    [Function("UploadFile")]
    public async Task<HttpResponseData> UploadFile(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "files/upload")] 
        HttpRequestData req)
    {
        try
        {
            var formData = await req.ReadFormAsync();
            var file = formData.Files.FirstOrDefault();
            
            if (file == null)
            {
                var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequest.WriteAsJsonAsync(new { error = "No file provided" });
                return badRequest;
            }
            
            var containerClient = _blobServiceClient.GetBlobContainerClient("uploads");
            await containerClient.CreateIfNotExistsAsync();
            
            var blobClient = containerClient.GetBlobClient(file.FileName);
            await blobClient.UploadAsync(file.OpenReadStream(), overwrite: true);
            
            _logger.LogInformation("File {FileName} uploaded successfully", file.FileName);
            
            var response = req.CreateResponse(HttpStatusCode.Created);
            await response.WriteAsJsonAsync(new 
            { 
                message = "File uploaded successfully",
                fileName = file.FileName,
                url = blobClient.Uri.ToString()
            });
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading file");
            var error = req.CreateResponse(HttpStatusCode.InternalServerError);
            await error.WriteAsJsonAsync(new { error = "Failed to upload file" });
            return error;
        }
    }
    
    /// <summary>
    /// Download file from blob storage
    /// GET /api/files/{fileName}
    /// </summary>
    [Function("DownloadFile")]
    public async Task<HttpResponseData> DownloadFile(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "files/{fileName}")] 
        HttpRequestData req,
        string fileName)
    {
        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient("uploads");
            var blobClient = containerClient.GetBlobClient(fileName);
            
            if (!await blobClient.ExistsAsync())
            {
                var notFound = req.CreateResponse(HttpStatusCode.NotFound);
                await notFound.WriteAsJsonAsync(new { error = "File not found" });
                return notFound;
            }
            
            var download = await blobClient.DownloadContentAsync();
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/octet-stream");
            response.Headers.Add("Content-Disposition", $"attachment; filename=\"{fileName}\"");
            await response.WriteBytesAsync(download.Value.Content.ToArray());
            
            _logger.LogInformation("File {FileName} downloaded successfully", fileName);
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error downloading file {FileName}", fileName);
            var error = req.CreateResponse(HttpStatusCode.InternalServerError);
            await error.WriteAsJsonAsync(new { error = "Failed to download file" });
            return error;
        }
    }
    
    /// <summary>
    /// List files in storage
    /// GET /api/files
    /// </summary>
    [Function("ListFiles")]
    public async Task<HttpResponseData> ListFiles(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "files")] 
        HttpRequestData req)
    {
        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient("uploads");
            var files = new List<object>();
            
            await foreach (var blob in containerClient.GetBlobsAsync())
            {
                files.Add(new
                {
                    name = blob.Name,
                    size = blob.Properties.ContentLength,
                    lastModified = blob.Properties.LastModified,
                    contentType = blob.Properties.ContentType
                });
            }
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { files });
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error listing files");
            var error = req.CreateResponse(HttpStatusCode.InternalServerError);
            await error.WriteAsJsonAsync(new { error = "Failed to list files" });
            return error;
        }
    }
    
    /// <summary>
    /// Get secret from Key Vault (Key Vault behind private endpoint)
    /// GET /api/config/{secretName}
    /// </summary>
    [Function("GetSecret")]
    public async Task<HttpResponseData> GetSecret(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "config/{secretName}")] 
        HttpRequestData req,
        string secretName)
    {
        try
        {
            // Validate secret name to prevent unauthorized access
            var allowedSecrets = new[] { "DatabaseConnectionString", "ApiKey", "ServiceEndpoint" };
            if (!allowedSecrets.Contains(secretName, StringComparer.OrdinalIgnoreCase))
            {
                var forbidden = req.CreateResponse(HttpStatusCode.Forbidden);
                await forbidden.WriteAsJsonAsync(new { error = "Access to this secret is not allowed" });
                return forbidden;
            }
            
            var secret = await _secretClient.GetSecretAsync(secretName);
            
            _logger.LogInformation("Secret {SecretName} retrieved successfully", secretName);
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { value = secret.Value.Value });
            return response;
        }
        catch (Azure.RequestFailedException ex) when (ex.Status == 404)
        {
            var notFound = req.CreateResponse(HttpStatusCode.NotFound);
            await notFound.WriteAsJsonAsync(new { error = "Secret not found" });
            return notFound;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving secret {SecretName}", secretName);
            var error = req.CreateResponse(HttpStatusCode.InternalServerError);
            await error.WriteAsJsonAsync(new { error = "Failed to retrieve secret" });
            return error;
        }
    }
    
    /// <summary>
    /// Health check endpoint
    /// GET /api/health
    /// </summary>
    [Function("HealthCheck")]
    public async Task<HttpResponseData> HealthCheck(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] 
        HttpRequestData req)
    {
        var healthStatus = new
        {
            status = "Healthy",
            timestamp = DateTime.UtcNow,
            checks = new
            {
                storage = await CheckStorageHealthAsync(),
                keyVault = await CheckKeyVaultHealthAsync()
            }
        };
        
        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(healthStatus);
        return response;
    }
    
    private async Task<object> CheckStorageHealthAsync()
    {
        try
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient("uploads");
            await containerClient.ExistsAsync();
            return new { status = "Healthy", message = "Storage connection successful" };
        }
        catch (Exception ex)
        {
            return new { status = "Unhealthy", message = ex.Message };
        }
    }
    
    private async Task<object> CheckKeyVaultHealthAsync()
    {
        try
        {
            // Try to list secrets (doesn't expose values)
            await foreach (var _ in _secretClient.GetPropertiesOfSecretsAsync().AsPages().Take(1))
            {
                break;
            }
            return new { status = "Healthy", message = "Key Vault connection successful" };
        }
        catch (Exception ex)
        {
            return new { status = "Unhealthy", message = ex.Message };
        }
    }
}
```

### 9.8 Program.cs Configuration

```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((context, services) =>
    {
        // Use managed identity for authentication
        var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
        {
            ManagedIdentityClientId = Environment.GetEnvironmentVariable("ManagedIdentityClientId")
        });
        
        // Register BlobServiceClient with managed identity
        var storageAccountName = Environment.GetEnvironmentVariable("IntegrationStorage__accountName");
        services.AddSingleton(new BlobServiceClient(
            new Uri($"https://{storageAccountName}.blob.core.windows.net"),
            credential));
        
        // Register SecretClient with managed identity
        var keyVaultUri = Environment.GetEnvironmentVariable("KeyVaultUri");
        services.AddSingleton(new SecretClient(new Uri(keyVaultUri), credential));
    })
    .Build();

await host.RunAsync();
```

### 9.9 Security Recommendations for Client Access

| Recommendation | Priority | Description |
|----------------|----------|-------------|
| Use Azure AD Authentication | High | Always use OAuth 2.0/OIDC instead of function keys for production |
| Implement IP Restrictions | High | Whitelist known client IP ranges |
| Enable Rate Limiting | Medium | Use API Management or custom middleware |
| Use HTTPS Only | High | Never allow HTTP connections |
| Validate Input | High | Sanitize all file names and parameters |
| Log All Access | High | Enable diagnostic logging for audit trail |
| Rotate Secrets Regularly | Medium | Use Key Vault auto-rotation where possible |
| Implement CORS | Medium | Restrict allowed origins for browser clients |

---

## 10. Bicep Module Changes

### 11.1 New Modules Required

#### 9.1.1 privateEndpoint.bicep

```bicep
// Private Endpoint Module
// Creates a private endpoint for Azure resources

@description('Name of the private endpoint')
param privateEndpointName string

@description('Azure region')
param location string

@description('Tags')
param tags object = {}

@description('Subnet ID for the private endpoint')
param subnetId string

@description('Resource ID of the target resource')
param privateLinkServiceId string

@description('Group IDs for the private link (e.g., blob, vault)')
param groupIds array

@description('Private DNS Zone IDs for registration')
param privateDnsZoneIds array = []

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (length(privateDnsZoneIds) > 0) {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [for (zoneId, i) in privateDnsZoneIds: {
      name: 'config${i}'
      properties: {
        privateDnsZoneId: zoneId
      }
    }]
  }
}

output id string = privateEndpoint.id
output name string = privateEndpoint.name
output networkInterfaceId string = privateEndpoint.properties.networkInterfaces[0].id
```

#### 9.1.2 privateDnsZone.bicep

```bicep
// Private DNS Zone Module
// Creates a private DNS zone and links it to VNet

@description('Name of the private DNS zone')
param zoneName string

@description('Tags')
param tags object = {}

@description('VNet IDs to link')
param virtualNetworkIds array = []

@description('Enable auto-registration')
param autoRegistration bool = false

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  tags: tags
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in virtualNetworkIds: {
  name: 'vnet-link-${i}'
  parent: privateDnsZone
  location: 'global'
  tags: tags
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: autoRegistration
  }
}]

output id string = privateDnsZone.id
output name string = privateDnsZone.name
```

#### 9.1.3 networkSecurityGroup.bicep

```bicep
// Network Security Group Module
// Creates NSG with security rules

@description('Name of the NSG')
param nsgName string

@description('Azure region')
param location string

@description('Tags')
param tags object = {}

@description('Security rules')
param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        priority: rule.priority
        direction: rule.direction
        access: rule.access
        protocol: rule.?protocol ?? '*'
        sourceAddressPrefix: rule.?sourceAddressPrefix ?? '*'
        sourcePortRange: rule.?sourcePortRange ?? '*'
        destinationAddressPrefix: rule.?destinationAddressPrefix ?? '*'
        destinationPortRange: rule.?destinationPortRange ?? '*'
      }
    }]
  }
}

output id string = nsg.id
output name string = nsg.name
```

### 9.2 Modified Modules

#### 9.2.1 storageAccount.bicep Changes

Add parameters for private endpoint configuration:

```bicep
@description('Enable private endpoints')
param enablePrivateEndpoints bool = false

@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

@description('Private DNS zone IDs for each service')
param privateDnsZoneIds object = {
  blob: ''
  file: ''
  queue: ''
  table: ''
}
```

#### 9.2.2 keyVault.bicep Changes

Add parameters for private endpoint configuration:

```bicep
@description('Enable private endpoint')
param enablePrivateEndpoint bool = false

@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

@description('Private DNS zone ID for Key Vault')
param privateDnsZoneId string = ''
```

#### 9.2.3 functionApp.bicep Changes

Add VNet-specific settings:

```bicep
@description('Enable VNet content share access')
param vnetContentShareEnabled bool = false

@description('Enable VNet image pull')
param vnetImagePullEnabled bool = false

@description('Number of private ports for VNet')
param vnetPrivatePortsCount int = 2
```

---

## 11. Implementation Plan

### 11.1 Phase 1: Foundation (Week 1)

| Task | Description | Priority |
|------|-------------|----------|
| 1.1 | Create `privateEndpoint.bicep` module | High |
| 1.2 | Create `privateDnsZone.bicep` module | High |
| 1.3 | Create `networkSecurityGroup.bicep` module | Medium |
| 1.4 | Update `storageAccount.bicep` with private endpoint support | High |
| 1.5 | Update `keyVault.bicep` with private endpoint support | High |

### 11.2 Phase 2: Integration (Week 2)

| Task | Description | Priority |
|------|-------------|----------|
| 2.1 | Update `functionApp.bicep` with VNet settings | High |
| 2.2 | Update `common/main.bicep` with private DNS zones | High |
| 2.3 | Update `standardIntegration.bicep` with private endpoints | High |
| 2.4 | Create parameter file updates for all environments | Medium |
| 2.5 | Update deployment workflows | Medium |

### 11.3 Phase 3: Testing (Week 3)

| Task | Description | Priority |
|------|-------------|----------|
| 3.1 | Deploy to dev environment | High |
| 3.2 | Validate Function App connectivity | High |
| 3.3 | Test Key Vault secret retrieval | High |
| 3.4 | Test Storage Account operations | High |
| 3.5 | Performance testing | Medium |

### 11.4 Phase 4: Production Rollout (Week 4)

| Task | Description | Priority |
|------|-------------|----------|
| 4.1 | Deploy to test environment | High |
| 4.2 | Deploy to UAT environment | High |
| 4.3 | Deploy to production environment | High |
| 4.4 | Monitor and validate | High |
| 4.5 | Update documentation | Medium |

---

## 12. Testing and Validation

### 12.1 Connectivity Tests

```powershell
# Test Storage Account connectivity from Function App
# Use Kudu console or deployment slot

# Test blob endpoint resolution
nslookup <storage-account>.blob.core.windows.net

# Expected: Returns private IP (10.0.2.x)

# Test Key Vault connectivity
nslookup <key-vault>.vault.azure.net

# Expected: Returns private IP (10.0.2.x)
```

### 12.2 Function App Tests

```csharp
// Health check endpoint to validate connectivity
[Function("HealthCheck")]
public async Task<HttpResponseData> HealthCheck(
    [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] HttpRequestData req)
{
    var response = req.CreateResponse(HttpStatusCode.OK);
    
    var healthStatus = new
    {
        Status = "Healthy",
        Timestamp = DateTime.UtcNow,
        Checks = new
        {
            Storage = await CheckStorageConnectivityAsync(),
            KeyVault = await CheckKeyVaultConnectivityAsync(),
            ServiceBus = await CheckServiceBusConnectivityAsync()
        }
    };
    
    await response.WriteAsJsonAsync(healthStatus);
    return response;
}
```

### 12.3 Validation Checklist

| Test | Expected Result | Pass/Fail |
|------|-----------------|-----------|
| DNS resolution for Storage blob endpoint | Private IP returned | |
| DNS resolution for Storage file endpoint | Private IP returned | |
| DNS resolution for Key Vault endpoint | Private IP returned | |
| Function App can read blob | Success | |
| Function App can write blob | Success | |
| Function App can read secrets | Success | |
| Function App can write to queue | Success | |
| Public access to Storage denied | 403 Forbidden | |
| Public access to Key Vault denied | 403 Forbidden | |

---

## 13. Monitoring and Diagnostics

### 13.1 Diagnostic Settings

Enable diagnostics for all resources:

```bicep
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${resourceName}-diagnostics'
  scope: resource
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
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
```

### 13.2 Alerts

#### Private Endpoint Connection Alerts

```bicep
resource privateEndpointAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${resourceName}-pe-connection-alert'
  location: 'global'
  properties: {
    severity: 1
    enabled: true
    scopes: [privateEndpoint.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ConnectionStatus'
          metricName: 'PEConnectionApprovalStatus'
          operator: 'NotEquals'
          threshold: 1  // 1 = Approved
          timeAggregation: 'Average'
        }
      ]
    }
  }
}
```

### 13.3 Log Analytics Queries

#### Query: Failed Private Endpoint Connections

```kusto
AzureDiagnostics
| where Category == "PrivateEndpointConnections"
| where OperationName == "PrivateEndpointConnectionsOperations"
| where ResultType != "Success"
| project TimeGenerated, Resource, OperationName, ResultType, ResultDescription
| order by TimeGenerated desc
```

#### Query: Storage Account Access Attempts

```kusto
StorageBlobLogs
| where OperationName in ("GetBlob", "PutBlob", "DeleteBlob")
| where StatusCode != 200
| project TimeGenerated, AccountName, OperationName, StatusCode, StatusText, CallerIpAddress
| order by TimeGenerated desc
```

---

## 14. Rollback Strategy

### 14.1 Rollback Triggers

- Function App cannot connect to Storage
- Function App cannot retrieve secrets from Key Vault
- Deployment failures
- Performance degradation > 50%

### 14.2 Rollback Steps

1. **Immediate**: Re-enable public access temporarily
   ```bicep
   publicNetworkAccess: 'Enabled'
   networkAcls: {
     defaultAction: 'Allow'
   }
   ```

2. **Short-term**: Restore service endpoints
   ```bicep
   serviceEndpoints: [
     { service: 'Microsoft.Storage' }
     { service: 'Microsoft.KeyVault' }
   ]
   ```

3. **Long-term**: Investigate and fix private endpoint issues

### 14.3 Rollback Parameter File

Maintain a rollback parameter file for each environment:

```json
{
  "parameters": {
    "enablePrivateEndpoints": { "value": false },
    "publicNetworkAccess": { "value": "Enabled" },
    "networkAclDefaultAction": { "value": "Allow" }
  }
}
```

---

## 15. Security Checklist

### 15.1 Pre-Deployment

- [ ] Private DNS zones created and linked to VNet
- [ ] NSG rules reviewed and approved
- [ ] Managed identity permissions configured
- [ ] Key Vault RBAC enabled
- [ ] Storage account public access disabled
- [ ] TLS 1.2 enforced on all resources
- [ ] Diagnostic settings configured

### 15.2 Post-Deployment

- [ ] DNS resolution verified (returns private IPs)
- [ ] Function App connectivity tested
- [ ] Public access denial verified
- [ ] Audit logs enabled and collecting
- [ ] Alerts configured and tested
- [ ] Documentation updated

### 15.3 Ongoing

- [ ] Regular security assessments
- [ ] Network traffic analysis
- [ ] Access pattern review
- [ ] Certificate renewal monitoring
- [ ] Compliance verification

---

## Appendix A: Resource Naming Conventions

| Resource Type | Naming Pattern | Example |
|---------------|----------------|---------|
| Private Endpoint | `{resource-name}-{subresource}-pe` | `staccount-blob-pe` |
| Private DNS Zone | `privatelink.{service}.core.windows.net` | `privatelink.blob.core.windows.net` |
| NSG | `{prefix}-{env}-{subnet}-nsg` | `edmo-dev-integration-nsg` |
| DNS Zone Link | `{vnet-name}-link` | `edmo-dev-sdc-vnet-link` |

## Appendix B: IP Address Planning

| Subnet | Address Range | Usable IPs | Purpose |
|--------|---------------|------------|---------|
| integration-subnet | 10.0.1.0/24 | 251 | Function Apps, Logic Apps |
| private-endpoint-subnet | 10.0.2.0/24 | 251 | Private Endpoints |
| (Reserved) | 10.0.3.0/24 | 251 | Future expansion |

## Appendix C: Azure Service Tags

| Service Tag | Purpose |
|-------------|---------|
| Storage | Azure Storage services |
| AzureKeyVault | Azure Key Vault |
| ServiceBus | Azure Service Bus |
| AzureMonitor | Azure Monitor and Application Insights |
| AzureCloud | All Azure datacenter IPs |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-01-19 | Architecture Team | Initial specification |
| 1.1.0 | 2026-01-19 | Architecture Team | Added Section 9: Remote Client Access Patterns with detailed examples for C#, Python, and PowerShell clients |

---

**Document Status**: Draft - Pending Review
