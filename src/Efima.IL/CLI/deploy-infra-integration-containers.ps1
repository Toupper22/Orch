param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev'
)

# Load shared scripts
. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

# Resource group.
Set-DefaultResourceGroup $targetResourceGroup

# Secure storage - Allow us to access.
if ($useSecureStorage) {

	# NOTE !!! This wasn't reliable. Sometimes got 'The request may be blocked by network rules of storage account.'.
	#
	# Get this execution's (DevOps pipeline) IP and allow access from that.
	#$publicIP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content
	#az storage account network-rule add --account-name $targetStorageName --ip-address $publicIP

	# Allow access temporarily in order to be able to e.g. create containers. See Configure-SecureStorage.
	Write-Host Temporarily allow access to secure storage.
	az storage account update --name $targetStorageName --default-action Allow
	Confirm-Error

	Write-Host Sleep 100 seconds.
	Start-Sleep -Seconds 100
}

# We assume that the common integration infra has been deployed.
# Additional storage containers.
$targetStorageContainerNames = @()
if ($archContainer) {
	$targetStorageContainerNames += @(
		$archContainer
	)
}
if ($archContainers) {
	$targetStorageContainerNames += $archContainers
}
if ($archContainerPrefix) {
	$targetStorageContainerNames += @(
		"$archContainerPrefix-success",
		"$archContainerPrefix-failure"
	)
}
Publish-StorageContainers $targetStorageName $targetStorageContainerNames | Out-Null

# Storage tables
if ($useTables) {
	$targetStorageTableNames = $storageTableNames
	Publish-StorageTables $targetStorageName $targetStorageTableNames | Out-Null
}

# Table contents
if ($tableEntities) {
	foreach ($partitionKey in $tableEntities.keys) {
		Write-Host "Found partition key '$partitionKey'."
	}
	$targetTableName = $tableName
	foreach ($partitionKey in $tableEntities.keys) {
		Insert-TableEntities $targetStorageName $targetTableName $partitionKey $tableEntities[$partitionKey] | Out-Null
	}
}

# Secure storage - Remove the network rule.
if ($useSecureStorage) {
	Write-Host Deny access to secure storage.
	#az storage account network-rule remove --account-name $targetStorageName --ip-address $publicIP
	az storage account update --name $targetStorageName --default-action Deny
	Confirm-Error
}
