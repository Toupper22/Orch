$intGroupName = 'integration-nomentia'
$intGroupShort = 'intnoment'

# Needed resources
$useKeyvault = $true
$useStorage = $true
$useTables = $true
$useTableApiConn = $true
$useBlobApiConn = $false

$keyvaultName = if ($useSharedKeyvault) {"kv-$eilCustomer-$eilGroupName-$tier"} else {"kv-$customer-$intGroupShort-$tier"}

# Initial values. Does not over-write.
$tableEntities = @{
	SFTP = @{
		Host = 'efimasftpblobtest.blob.core.windows.net'
		Username = 'efimasftpblobtest.efimasftpdev'
		PasswordSecret = 'NomentiaSftpPassword'
		Port = 22
		DeleteAfterDownload = if ($tier -eq 'prod') { $true } else { $false }
		KeyvaultName = $keyvaultName
		TransferName = $intGroupShort
	}
}
