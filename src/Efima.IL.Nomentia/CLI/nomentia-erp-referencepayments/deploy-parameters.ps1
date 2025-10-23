$intName = "integration-nomentia-$erpName-refpayments"
$intGroupName = 'integration-nomentia'
$intGroupShort = 'intnoment'
$archContainerPrefix = 'refpayments'

# Use deploy-logicapp-integration-sftp.ps1 without transformation.
$processTemplateIdentifier = 'connection'
$conOutGroupName = "connection-$erpName"
$conOutWorkflowName = 'storage-putfile'

# Initial values. Does not over-write.
$partitionKey = 'ReferencePayment'
$conOutPartitionKey = 'D365F_ReferencePayment'
$conInPartitionKey = 'SFTP' # Use common Nomentia SFTP account.
$tableEntities = @{
	"$partitionKey" = @{
		SftpFolder = 'nomentia/refpayments'
		ArchiveInputEnabled = $true
		ArchiveOutputEnabled = $false
		ArchiveInputOnErrorEnabled = $false
		ArchiveOutputOnErrorEnabled = $false
	}
	# D365F storage
	"$conOutPartitionKey" = @{
		Path = 'refpayments/in'
	}
}

# List-scheduler
$splitRowKey = 'SftpFolder'
$splitTargetKey = 'Folder'
$splitPartitionKey = $partitionKey
