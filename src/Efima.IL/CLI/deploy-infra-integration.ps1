param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev'
)

# Load variables and scripts.
. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

# Resource group
Publish-ResourceGroup $targetResourceGroup
Set-DefaultResourceGroup $targetResourceGroup

# Keyvault
if ($useKeyvault) {
	$keyvaultName = $targetKeyvaultName
	Publish-KeyVault $keyvaultName $tier
}

# Storage account for archiving & tables
if ($useStorage) {
	Publish-StorageAccount -AccountName $targetStorageName `
		-KeyvaultName $keyvaultName `
		-KeyvaultSecretName $archStorageSecretName `
		-PolicyFile "delete-90d-old-blobs-policy.json" `
		-SecureStorage $useSecureStorage `
		| Out-Null

	# Success/failure containers
	if ($archContainerPrefix) {
		$targetStorageContainerNames = @(
			"$archContainerPrefix-success",
			"$archContainerPrefix-failure"
		)
		Publish-StorageContainers $targetStorageName $targetStorageContainerNames | Out-Null
	}
	# Additional containers
	if ($archContainers) {
		Publish-StorageContainers $targetStorageName $archContainers | Out-Null
	}
}
## Storage tables
if ($useTables) {
	$targetStorageTableNames = $storageTableNames
	Publish-StorageTables $targetStorageName $targetStorageTableNames | Out-Null

	$targetTableName = $tableName
	if ($tableEntities) {
		foreach ($partitionKey in $tableEntities.keys) {
			Insert-TableEntities $targetStorageName $targetTableName $partitionKey $tableEntities[$partitionKey] | Out-Null
		}
	}
}
## Storage VNet
if ($useSharedVnet -and $useStorage) {
	Configure-StorageVnet -AccountName $targetStorageName | Out-Null
}
## Secure storage
if ($useSecureStorage -and $useStorage) {
	Configure-SecureStorage -AccountName $targetStorageName | Out-Null
}

# Storage account for connectivity
if ($useConnStorage) {
	Publish-StorageAccount -AccountName $targetConnStorageName `
		-KeyvaultName $keyvaultName `
		-KeyvaultSecretName $connStorageSecretName `
		-PolicyFile "delete-90d-old-blobs-policy.json" `
		-SecureStorage $useSecureConnStorage `
		-EnableSftp $enableSftpConnStorage `
		| Out-Null

	# Containers
	if ($connContainers) {
		Publish-StorageContainers $targetConnStorageName $connContainers | Out-Null
	}
}

# Target domain identity
$identityId = az identity create --name $targetIdentityName --query principalId -o tsv
Confirm-Error

# Also give the shared identity an access to the keyvault.
$sharedIdentityId = az identity show --name $sharedIdentityName `
	--resource-group $sharedResourceGroup `
	--query principalId `
	--output tsv
Confirm-Error

# Give access to keyvault secrets.
if ($useKeyvault) {
	$secretPermissionObjectIds = @(
		$identityId
		$sharedIdentityId
	)
	## Possible additional objects needing access
	if ($userObjectIds) {
		$secretPermissionObjectIds += $userObjectIds
	}
	Configure-KeyVaultSecretPermissions $keyvaultName $secretPermissionObjectIds
}
if ($useSharedKeyvault) {
	$secretPermissionObjectIds = @(
		$identityId
	)
	Configure-KeyVaultSecretPermissions $sharedKeyvaultName $secretPermissionObjectIds $sharedResourceGroup
}

# Service bus
if ($useServiceBus) {
	Publish-ServiceBusNamespace -Name $targetServiceBusNamespace -ResourceGroup $targetResourceGroup -KeyvaultName $targetKeyvaultName
}
## Queues
if ($serviceBusQueueNames) {
	Publish-ServiceBusQueues -Namespace $targetServiceBusNamespace -QueueNames $serviceBusQueueNames
}

# Assign Reader role to the shared Managed Identity for the Target Resource Group
#az role assignment create --assignee $sharedIdentityId --role "Reader" --resource-group $targetResourceGroup
$rscGroupId = "/subscriptions/$sharedSubscriptionId/resourceGroups/$targetResourceGroup"
az role assignment create --role 'Reader' --assignee-object-id $sharedIdentityId --assignee-principal-type 'ServicePrincipal' --scope $rscGroupId
Confirm-Error

$templateParams = @{
	Tier = $tier
	CustomerId = $customer
	IntegrationGroup = $intGroupName
	IntegrationGroupShort = $intGroupShort
}

# Keyvault API connection
if ($useKeyvaultApiConn) {
	$templatePath = "api-conn-keyvault-template.json"
	Publish-ARMTemplate $templatePath $templateParams | Out-Null
}

# Storage table API connection
if ($useTableApiConn) {
	$templatePath = "api-conn-tablestorage-template.json"
	Publish-ARMTemplate $templatePath $templateParams | Out-Null

	# Assign contributor role to get read-write permission.
	az role assignment create --role 'Storage Table Data Contributor' --assignee-object-id $identityId --assignee-principal-type 'ServicePrincipal' --scope $rscGroupId
	Confirm-Error

	# Assign reader role to the shared ID.
	az role assignment create --role 'Storage Table Data Reader' --assignee-object-id $sharedIdentityId --assignee-principal-type 'ServicePrincipal' --scope $rscGroupId
	Confirm-Error
}

# Blob storage API connection. Connection string auth.
if ($useBlobApiConn) {
	$templatePath = "api-conn-blobstorage-template.json"
	Publish-ARMTemplate $templatePath $templateParams | Out-Null
}

# Blob storage API connection. Managed ID auth.
if ($useBlobApiConnId -or $useConnBlobApiConnId) {
	# Archiving
	if ($useBlobApiConnId) {
		$templatePath = "api-conn-blobstorage-id-template.json"
		$templateParams.StorageAccount = $targetStorageName
		Publish-ARMTemplate $templatePath $templateParams | Out-Null
	}

	# Connectivity
	if ($useConnBlobApiConnId) {
		$templatePath = "api-conn-blobstorage-id-template.json"
		$templateParams.StorageAccount = $targetConnStorageName
		Publish-ARMTemplate $templatePath $templateParams | Out-Null
	}
	$templateParams.StorageAccount = $null

	# Assign contributor role to get read-write permission.
	az role assignment create --role 'Storage Blob Data Contributor' --assignee-object-id $identityId --assignee-principal-type 'ServicePrincipal' --scope $rscGroupId
	Confirm-Error
}

# Service bus API connection
if ($useServiceBusApiConnId) {
	$templatePath = 'api-conn-servicebus-template.json'
	Publish-ARMTemplate $templatePath $templateParams | Out-Null
}
elseif ($useServiceBusApiConnString) {
	# Service Bus connection setup - Read connection string from KeyVault.
	$templatePath = "api-conn-string-servicebus-template.json"
	$templateParams.KeyVaultName = if ($useSharedKeyvault) { $sharedKeyvaultName } else { $keyvaultName }
	$templateParams.ServiceBusConnectionStringSecretName = $serviceBusConnectionName

	# Resolve the actual connection string from Key Vault (caller must have Secrets/Get)
	$sbConnString = az keyvault secret show `
		--vault-name $templateParams.KeyVaultName `
		--name $templateParams.ServiceBusConnectionStringSecretName `
		--query value -o tsv

	if ([string]::IsNullOrWhiteSpace($sbConnString)) {
		throw "Service Bus connection string secret '$($templateParams.ServiceBusConnectionStringSecretName)' not found or empty in Key Vault '$($templateParams.KeyVaultName)'."
	}

	# Pass the resolved value to the ARM template (secureString param)
	$templateParams.ServiceBusConnectionString = $sbConnString

	Publish-ARMTemplate $templatePath $templateParams | Out-Null
}

# D365 Service Bus direct read by using managed ID.
if ($useDirectServiceBusRead) {
	$d365ResourceGroup = "rg-$eilCustomer-connection-$erpName-$tier"
	$rscGroupId = "/subscriptions/$sharedSubscriptionId/resourceGroups/$d365ResourceGroup"
	az role assignment create --role 'Azure Service Bus Data Receiver' --assignee-object-id $identityId --assignee-principal-type 'ServicePrincipal' --scope $rscGroupId
	Confirm-Error
}

# Function App hosting plan
if ($functionAppPlanSku) {
	Publish-AppServicePlan $targetAppServicePlanName $functionAppPlanSku
}

# Static IP
if ($useStaticIp) {
	. .\deploy-infra-static-ip.ps1 -customer $customer -tier $tier
}

# Api management
if ($useApim) {
	. .\deploy-apim-infra.ps1 -tier $tier
}
