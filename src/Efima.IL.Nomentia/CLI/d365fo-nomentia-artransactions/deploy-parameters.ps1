$intName = "integration-$erpName-nomentia-artransactions"
$intGroupName = 'integration-nomentia'
$intGroupShort = 'intnoment'
$archContainerPrefix = 'artransactions'

# Connections
$conInGroupName = "connection-$erpName"
$conInWorkflowName = 'dmf-export-package'
$conOutGroupName = $intGroupName
$conOutWorkflowName = 'sftpuploadfile'

# Needed resources
$useStorage = $true
$useTables = $true
$useTableApiConn = $true
$useBlobApiConn = $false

# Function App
$trFunctionName = 'D365ArTransactionsTransform'

# LogicApp templates
$processTemplateIdentifier = 'transform'
$starterTemplateIdentifier = 'dmf-export'
$schedulerTemplateIdentifier = 'list'

# Initial values. Does not over-write.
$tableEntities = @{
	ArTransaction = @{
		Company = 'list;here'
		DefinitionGroup = ''
		SftpFolder = 'nomentia/artransactions'
		ArchiveInputEnabled = $true
		ArchiveOutputEnabled = $false
		ArchiveInputOnErrorEnabled = $false
		ArchiveOutputOnErrorEnabled = $true
	}
}
$partitionKey = 'ArTransaction'
# Use common Nomentia SFTP settings.
$conOutPartitionKey = 'SFTP'
