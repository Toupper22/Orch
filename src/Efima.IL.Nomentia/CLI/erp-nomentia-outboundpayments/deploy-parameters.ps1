$intName = "integration-$erpName-nomentia-outboundpayments"
$intGroupName = 'integration-nomentia'
$intGroupShort = 'intnoment'
$archContainerPrefix = 'outboundpayments'

# LogicApp templates
$processTemplateIdentifier = 'connection'
$handlerTemplateIdentifier = 'storage'
$starterTemplateIdentifier = 'storage'
$schedulerTemplateIdentifier = 'list'

# Source connection is ERP.
$conInGroupName = "connection-$erpName"

# Target connection is SFTP. No transformation.
$conOutGroupName = $eilGroupName
$conOutType = 'Function'
$conOutFunctionName = 'SftpUploadFile'
$conOutFunctionAppName = 'sftp'

# Initial values. Does not over-write.
$partitionKey = 'OutboundPayments'
$conOutPartitionKey = 'SFTP' # Use common Nomentia SFTP account.
$tableEntities = @{
	"$partitionKey" = @{
		StorageFolder = 'outboundpayments'
		ArchiveInputEnabled = $false
		ArchiveOutputEnabled = $false
		ArchiveInputOnErrorEnabled = $true
		ArchiveOutputOnErrorEnabled = $false
	}
	# Add to the common Nomentia settings. Used by upload only.
	"$conOutPartitionKey" = @{
		Folder = 'nomentia/sepapayments'
	}
}

# List-scheduler
$splitRowKey = 'StorageFolder'
$splitTargetKey = 'Path'
$splitPartitionKey = $partitionKey
