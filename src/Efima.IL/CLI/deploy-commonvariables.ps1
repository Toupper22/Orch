param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$true)][ValidateSet("dev", "main", "test", "uat", "prod")][String] $tier = "dev"
)

# Resource abbreviations: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

# Customer-specific parameters.
. .\deploy-parameters-eil.ps1
. .\deploy-parameters.ps1

# Load common scripts.
. .\deploy-commonscripts.ps1

# Subscription
if ($eilSubscription) {
	$sharedSubscription = $eilSubscription
}
else {
	$sharedSubscription = "$customer-integration-$tier"
}

Set-DefaultLocation $location
Set-AzureSubscription $sharedSubscription

$sharedSubscriptionId = az account show --query id -o tsv

# Target system resources
if ($functionAppName -eq $null) {
	$functionAppName = $intGroupName
}
$targetCustomerGroup = "$customer-$intGroupName"
$targetResourceGroup = "rg-$targetCustomerGroup-$tier"            # Resource group
$targetKeyvaultName = "kv-$customer-$intGroupShort-$tier"         # Keyvault
$targetIdentityName = "id-$targetCustomerGroup-$tier"             # User-assigned identity
$targetFunctionAppName = "func-$customer-$functionAppName-$tier"  # Function App name
$targetAppServicePlanName = "plan-$targetCustomerGroup-$tier"     # Function App hosting plan
$targetFunctionStorageName = "stfunc$customer$intGroupShort$tier" # Function App storage account
$targetStorageName = "starch$customer$intGroupShort$tier"         # Archive storage account
$targetConnStorageName = "stconn$customer$intGroupShort$tier"     # Connectivity storage account
$targetVnetName = "vnet-$targetCustomerGroup-$tier"               # Virtual network
$targetSubnetName = "snet-$targetCustomerGroup-$tier"             # Virtual network's sub-network
$targetNatGateway = "ng-$targetCustomerGroup-$tier"               # NAT gateway
$targetServiceBusNamespace = "sb-$targetCustomerGroup-$tier"
$targetStdLogicAppName = "las-$targetCustomerGroup-$tier"         # Standard Logic App name

# EIL resources
$sharedCustomerGroup = "$eilCustomer-$eilGroupName"
$sharedResourceGroup = "rg-$sharedCustomerGroup-$tier"
$sharedKeyvaultName = "kv-$sharedCustomerGroup-$tier"
$sharedServiceBusNamespace = "sb-$sharedCustomerGroup-$tier"
$sharedIdentityName = "id-$sharedCustomerGroup-$tier"
$sharedAppServicePlanName = "plan-$sharedCustomerGroup-$tier"
$sharedFunctionAppName = "func-$sharedCustomerGroup-$tier"
$sharedVnetName = "vnet-$sharedCustomerGroup-$tier"
$sharedSubnetName = "snet-$sharedCustomerGroup-$tier"

# Storage account
$sharedStorageName = "starch$eilCustomer$eilGroupName$tier"
$sharedFunctionStorageName = "stfunc$eilCustomer$eilGroupName$tier"

# APIM
$publisherEmail = 'efima@efima.com'
$publisherName = 'Efima Oy'
$skuCount = '1'
$sharedApimName = "apim-$sharedCustomerGroup-$tier"
$targetApimVnetName = "vnet-apim-$targetCustomerGroup-$tier" # This is only used if expressroute and private link are used in APIM.
$apimPublicIpName = "pip-$sharedApimName" # IP is only deployed if APIM tier is set to premium or developer with VNET support

# Function app service plans
# Full resource ID needed since the function can be in a different resource group. Plus comparison.
$sharedFunctionAppPlan = "/subscriptions/$sharedSubscriptionId/resourceGroups/$sharedResourceGroup/providers/Microsoft.Web/serverfarms/$sharedAppServicePlanName"
if ($functionAppPlanSku) {
	$targetFunctionAppPlan = "/subscriptions/$sharedSubscriptionId/resourceGroups/$targetResourceGroup/providers/Microsoft.Web/serverfarms/$targetAppServicePlanName"
}

# Logging
# $sharedCustomerGroup is used in the name in case logs and errorcat are managed in a stand-alone resource group, usually called "shared" or "errors". Examples of this are Luvata or Volue.
# Otherwise, if there is only one resouce group per tier, $sharedCustomerGroup should be equal to the customer name.
$appInsightsName = "appi-$sharedCustomerGroup-$tier"
$logAnalyticsWorkspaceName  = "log-$sharedCustomerGroup-$tier"

# Template and parameter root paths. Nowadays flattened at deploy.
$sharedLogicAppRoot = "..\LogicApps"
$sharedCLIRoot = "..\CLI"
$sharedSbLogicAppRoot = "..\LogicApps"
$sharedSftpLogicAppRoot = "..\LogicApps"
$projectLogicAppRoot = "..\LogicApps"
