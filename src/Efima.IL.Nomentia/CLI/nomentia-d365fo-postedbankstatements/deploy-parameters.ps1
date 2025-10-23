$intName = "integration-nomentia-$erpName-postedbankstatements"
$intGroupName = 'integration-nomentia'
$intGroupShort = 'intnoment'
$archContainerPrefix = 'postedbankstatements'

# Use deploy-logicapp-integration-sftp.ps1 with transformation.
$processTemplateIdentifier = 'transform'
$trFunctionName = 'BankStatementTransform'
$conOutGroupName = "connection-$erpName"
$conOutWorkflowName = 'create-expense-journal'

# Initial values. Does not over-write.
$partitionKey = 'BankStatement'
$conOutPartitionKey = 'D365F_BankStatement'
$conInPartitionKey = 'SFTP' # Use common Nomentia SFTP settings.
$tableEntities = @{
	"$partitionKey" = @{
		SftpFolder = 'nomentia/postedbankstatements'
		ArchiveInputEnabled = $true
		ArchiveOutputEnabled = $false
		ArchiveInputOnErrorEnabled = $false
		ArchiveOutputOnErrorEnabled = $true
	}
	FunctionBankStatement = @{
		AccountType = 'Ledger'
		JournalName = 'TILIOTE'
		AccountDisplayValueFormat = '{Tili}-{Toimipaikka}-{Osasto}---'
		SkipRow = ''
		TaxGroupDimensionName = 'Alv'
	}
	D365F_BankStatement = @{
		PostJournal = 'Post'
		KeepJournalOnPostingError = 'NoCleanup'
		RecurringActivityId = 'todo'
		UseOData = $valueUseOData
		ODataMaxItems = $valueODataMaxItems
	}
}

# List-scheduler
$splitRowKey = 'SftpFolder'
$splitTargetKey = 'Folder'
$splitPartitionKey = $partitionKey
