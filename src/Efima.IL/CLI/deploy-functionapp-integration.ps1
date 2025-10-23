param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$true)][String]  $tier = "dev",
	[Parameter(Mandatory=$true)][String]  $zipfile
)

# Load variables and scripts.
. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

# Set resource group.
Set-DefaultResourceGroup $targetResourceGroup

$funcAppName = $targetFunctionAppName
$funcStorageName = $targetFunctionStorageName
$funcAppZipPath = "..\$zipfile"
$keyvaultName = $targetKeyvaultName

# Get target domain identity
$targetIdentity = az identity show --name $targetIdentityName | ConvertFrom-Json
Confirm-Error

# Function App configuration
#
$funcAppSettings = @(
	"FUNCTIONS_EXTENSION_VERSION=~$functionsVersion"
	"FUNCTIONS_INPROC_NET8_ENABLED=1"
	"FUNCTIONS_WORKER_RUNTIME=dotnet"
	"customer=$customer"
	"tier=$tier"
	"AZURE_CLIENT_ID=$($targetIdentity.clientId)"
)
#   Storage connection strings
if ($useStorage) {
	$funcAppSettings += @(
		"BlobConnectionString=`"@Microsoft.KeyVault(SecretUri=https://$keyvaultName.vault.azure.net/secrets/$archStorageSecretName/)`""
		"DefaultValueStorageConnection=`"@Microsoft.KeyVault(SecretUri=https://$keyvaultName.vault.azure.net/secrets/$archStorageSecretName/)`""
	)
}
#   Assume additional config is in a variable.
if ($eilFunctionAppConfig) {
	$funcAppSettings += $eilFunctionAppConfig
}
if ($functionAppConfig) {
	$funcAppSettings += $functionAppConfig
}

# Set hosting plan. Empty results in a default consumption-based plan (Y1). See Publish-FunctionApp.
if ($useSharedFunctionAppPlan) {
	$functionAppServicePlan = $sharedFunctionAppPlan
}
elseif ($functionAppPlanSku) {
	$functionAppServicePlan = $targetFunctionAppPlan
}

# Publish
# Assign the domain identity. Note that we had to add the AZURE_CLIENT_ID app setting too.
Publish-FunctionApp -FunctionAppName $funcAppName `
	-FuncStorageName $funcStorageName `
	-KeyvaultName $keyvaultName `
	-ZipPath $funcAppZipPath `
	-AppSettings $funcAppSettings `
	-PolicyFile $funcStoragePolicyFile `
	-SecureStorage $useSecureStorage `
	-UseSharedVnet $useSharedVnet `
	-ForceOutboundTrafficToVnet $forceOutboundTrafficToVnet `
	-ForceConfigureSecurity $forceFunctionAppSecurity `
	-AppServicePlan $functionAppServicePlan `
	-IdentityId $targetIdentity.id | Out-Null

# Configure funtion to use a dedicated Vnet & static IP. (As opposed to $useSharedVnet)
if ($useStaticIp) {
	Configure-FunctionAppVnet -FunctionAppName $funcAppName `
		-VnetName $targetVnetName `
		-SubnetName $targetSubnetName `
		-ForceOutboundTrafficToVnet $forceOutboundTrafficToVnet | Out-Null
}
