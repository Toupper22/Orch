# EIL example parameters
$customer = 'demo'
$erpName ='d365f'
$erpShort ='d365'

# General
$location = "westeurope"
$dailyMemoryTimeQuota = 200000
$functionsVersion = 4

$eilCustomer = 'efima'
$eilSubscription = 'efi-az-layer-dev-sub'
$eilGroupName = 'il'
$eilProject = 'Efima.IL'
$eilFunctionAppConfig = @(           # Applied to all functions - both EIL & integrations.
	"WEBSITE_RUN_FROM_PACKAGE=1"
	"WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT=1"
)
$eilServiceBusFunctionAppConfig = @( # Applied to EIL servicebus function only.
	"D365FOServiceBusConnectionString=`"@Microsoft.KeyVault(SecretUri=https://kv-$eilCustomer-$eilGroupName-$tier.vault.azure.net/secrets/D365FOServiceBusConnectionString/)`""
)

# Key-value pairs to be inserted into the Values & Conversions tables. A hashtable
# with key = partition key, value = a hashtable with the key-value pairs.
#
$eilValuesTableEntities = $null
$eilConversionsTableEntities = $null
$eilConversionsTablePartitionKey = $null
$tableRowKey = 1

# Infra resources
$eilUseKeyvaultApiConn = $false  # Keep false. No EIL logic app uses keyvault.
$eilUseTableApiConn = $false     # Table storage API connection
$eilUseServiceBus = $false       # D365 Service Bus
$eilUseStorage = $false          # Keep false since EIL storage is used by ErrorCat only and is created there.
$eilUseSecureStorage = if ($tier -eq 'dev') { $false } else { $true } # Access the storage account from vnet only.
$eilUseStaticIp = $eilUseSecureStorage    # Static IP, NAT gateway, and vnet & subnet.
$eilUseSharedVnet = $eilUseStaticIp       # Connect functions to the vnet/subnet.

# Function App hosting plan. E.g. B1 required for static IP.
$eilFunctionAppPlanSku = if ($tier -eq 'prod') { 'S1' } else { 'B1' }

# IP to white-list in e.g. secure storage.
$serviceIP = '217.149.56.100' # Efima public IP
$additionalServiceIPs = @()

# D365F OData concurrence. Currently affects the expense journal OData/DMF switching
# logic app (create-expense-journal-template.json) only - both OData and DMF.
# TODO Gain experience about this and possibly extend to other than expence journal too.
# TODO Is it ok to limit DMF too or should it be just OData?
$eilNumConcurrentRunsOData = 3 # Zero means unlimited.
$eilNumConcurrentWaitingOData = 50

# Error Categorization
#
# Client (application) ID. See the App registration resource. Note that in addition, one has to
# put the client secret into the keyvault. Use 'LogAnalyticsClientSecret' as the name of the secret.
# See App registration -> Certificates & secrets plus secrets.efima.com for the actual secret value.
$eilLogAnalyticsClientId = '9daed49d-d1cb-45eb-bd9d-25405c984449'
$eilLogAnalyticsTenantId = 'b190b61a-54a2-4e07-929c-9fa342bb1c6e'  # Microsoft Entra tenant (directory) ID. See the App registration resource.
$eilLogAnalyticsWorkspaceId = if ($tier -eq 'dev') { 'e58a8dd6-0625-48a9-90aa-044bb01ce5c9' }  # See the Log Analytics workspace resource.
	elseif ($tier -eq 'main') { 'f7722b55-9c0c-4004-86a9-e28872357dad' }
	else { '' }
$eilUseJiraErrorCategorization = $false  # NOTE Check agreement if the customer has paid for this!!!
$eilJiraRecipientEmail = if ($tier -ne 'prod') { 'heikki.rantanen@efima.com' } else { 'support@efima.com' }
$eilJiraServiceDeskId = 2
$eilJiraCustomer = 'Efima (000)'
$eilJiraOrganizationId = ''
$eilJiraDefaultAssigneeId = ''
$eilJiraIssueSummaryPrefix = if ($tier -eq 'prod') { "$customer" } else { "$customer TEST TICKET" }
$eilErrorCatEnabled = if ($tier -eq 'prod') { $true } else { $false }
$eilErrorCatRunRuleImport = $false

# SFTP switch scheduler.
# Note that the managed identity needs Storage Account Contributor role.
$sftpSwitcherResourceGroup = 'SftpTesting'
$eilSftpSwitchStorageName = 'sftpblobtest'

# Integration infra defaults. You can over-write in deploy-parameters.ps1.
#
# Infra resources
$useKeyvault = $false      # Deploy keyvault.
$useServiceBus = $false    # Deploy service bus namespace.
$useStaticIp = $false      # Deploy dedicated Vnet & static IP.
$useStorage = $false       # Deploy storage account for achiving.
$useTables = $false        # Create storage tables. See $storageTableNames.

# Connectivity storage account
$useConnStorage = $false         # Deploy storage account for connectivity.
$useSecureConnStorage = $eilUseSecureStorage  # Access the connectivity storage from vnet only.
$enableSftpConnStorage = $false  # Enable SFTP in the connectivity storage. (Mind the cost!)

# API connections
$useBlobApiConn = $false               # Deploy archive blob storage API connection with default (= access key) authentication.
$useBlobApiConnId = $false             # Deploy archive blob storage API connection with managed-ID authentication.
$useConnBlobApiConnId = $false         # Deploy connectivity blob storage API connection with managed-ID authentication.
$useServiceBusApiConnId = $false       # Deploy service bus API connection with managed-ID authentication.
$useServiceBusApiConnString = $false   # Deploy service bus API connection with connection string authentication.
$useKeyvaultApiConn = $false           # Deploy keyvault API connection with default authentication.
$useTableApiConn = $false              # Deploy table storage API connection with default (= managed-ID) authentication.

$useDirectServiceBusRead = $false      # Read/trigger directly from D365 service bus in logic app by using managed identity.
$useSecureStorage = $eilUseSecureStorage  # Access the storage account from vnet only.
$useSharedFunctionAppPlan = $true
$useSharedKeyvault = $false
$useSharedVnet = $useSecureStorage
$archContainerPrefix = 'orchestration'    # Archive container name prefix
$archStorageSecretName = 'BlobConnectionString'
$connStorageSecretName = 'ConnStorageConnectionString'
$forceOutboundTrafficToVnet = $null    # True/false explicitly enables/disables. Null does nothing.
$forceFunctionAppSecurity = $false     # Configure function app security for an existing function app too. (Requires $useStorage = $true.)
$functionAppConfig = $null             # In addition to $eilFunctionAppConfig.
$functionAppPlanSku = $null            # Null results in the default consumption-based plan (Y1).
$funcStoragePolicyFile = $null
$logicAppParams = @{}
$schedulerWorkflowState = 'Disabled'   # Scheduler deploy state. Other workflows are deployed to template default state, which is Enabled typically.
$serviceBusAuthenticationType = 'ManagedServiceIdentity'  # ManagedServiceIdentity -> Managed ID. Empty -> Connection string.
$serviceBusConnectionName = 'ServiceBusConnectionString'  # The name of the SB connection string in keyvault. Used by API connection.
$storageTableNames = @(
	"Values",
	"Conversions"
)
$tableName = $storageTableNames[0]
$sftpPasswordSecret = 'SftpPassword'

# Table partition keys for input, output, and orchestration parameter values, respectively.
$conInPartitionKey = $null
$conOutPartitionKey = $null
$partitionKey = 'Orchestration'

# Integration processor concurrence.
$numConcurrentRunsProcess = 1 # Zero means unlimited.
$numConcurrentWaitingProcess = 50

# Integration default table-values.
$valueUseOData = $true
$valueODataMaxItems = 20

# Assign Contributor role to resource groups for this group/assignee. Note that the
# service connection needs a permission to assign roles. Suitable only in subscriptions
# where the service connection is trusted and can't be abused.
# See Publish-ResourceGroup() in deploy-commonscripts.ps1.
$devgroup = $null
