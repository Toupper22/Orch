# Development Specification: Secure Function App Communication

## Document Information

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
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
9. [Bicep Module Changes](#9-bicep-module-changes)
10. [Implementation Plan](#10-implementation-plan)
11. [Testing and Validation](#11-testing-and-validation)
12. [Monitoring and Diagnostics](#12-monitoring-and-diagnostics)
13. [Rollback Strategy](#13-rollback-strategy)
14. [Security Checklist](#14-security-checklist)

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

## 9. Bicep Module Changes

### 9.1 New Modules Required

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

## 10. Implementation Plan

### 10.1 Phase 1: Foundation (Week 1)

| Task | Description | Priority |
|------|-------------|----------|
| 1.1 | Create `privateEndpoint.bicep` module | High |
| 1.2 | Create `privateDnsZone.bicep` module | High |
| 1.3 | Create `networkSecurityGroup.bicep` module | Medium |
| 1.4 | Update `storageAccount.bicep` with private endpoint support | High |
| 1.5 | Update `keyVault.bicep` with private endpoint support | High |

### 10.2 Phase 2: Integration (Week 2)

| Task | Description | Priority |
|------|-------------|----------|
| 2.1 | Update `functionApp.bicep` with VNet settings | High |
| 2.2 | Update `common/main.bicep` with private DNS zones | High |
| 2.3 | Update `standardIntegration.bicep` with private endpoints | High |
| 2.4 | Create parameter file updates for all environments | Medium |
| 2.5 | Update deployment workflows | Medium |

### 10.3 Phase 3: Testing (Week 3)

| Task | Description | Priority |
|------|-------------|----------|
| 3.1 | Deploy to dev environment | High |
| 3.2 | Validate Function App connectivity | High |
| 3.3 | Test Key Vault secret retrieval | High |
| 3.4 | Test Storage Account operations | High |
| 3.5 | Performance testing | Medium |

### 10.4 Phase 4: Production Rollout (Week 4)

| Task | Description | Priority |
|------|-------------|----------|
| 4.1 | Deploy to test environment | High |
| 4.2 | Deploy to UAT environment | High |
| 4.3 | Deploy to production environment | High |
| 4.4 | Monitor and validate | High |
| 4.5 | Update documentation | Medium |

---

## 11. Testing and Validation

### 11.1 Connectivity Tests

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

### 11.2 Function App Tests

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

### 11.3 Validation Checklist

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

## 12. Monitoring and Diagnostics

### 12.1 Diagnostic Settings

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

### 12.2 Alerts

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

### 12.3 Log Analytics Queries

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

## 13. Rollback Strategy

### 13.1 Rollback Triggers

- Function App cannot connect to Storage
- Function App cannot retrieve secrets from Key Vault
- Deployment failures
- Performance degradation > 50%

### 13.2 Rollback Steps

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

### 13.3 Rollback Parameter File

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

## 14. Security Checklist

### 14.1 Pre-Deployment

- [ ] Private DNS zones created and linked to VNet
- [ ] NSG rules reviewed and approved
- [ ] Managed identity permissions configured
- [ ] Key Vault RBAC enabled
- [ ] Storage account public access disabled
- [ ] TLS 1.2 enforced on all resources
- [ ] Diagnostic settings configured

### 14.2 Post-Deployment

- [ ] DNS resolution verified (returns private IPs)
- [ ] Function App connectivity tested
- [ ] Public access denial verified
- [ ] Audit logs enabled and collecting
- [ ] Alerts configured and tested
- [ ] Documentation updated

### 14.3 Ongoing

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

---

**Document Status**: Draft - Pending Review
