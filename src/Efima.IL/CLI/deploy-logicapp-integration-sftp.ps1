param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev',
	[Parameter(Mandatory=$false)][bool] $DeployProcess = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployHandler = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployStarter = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployScheduler = $false, # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp0 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp1 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp2 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp3 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp4 = $true
)

# Load variables and scripts.
. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

# Resource group.
Set-DefaultResourceGroup $targetResourceGroup

# Template parameters
$templateParams = @{
	Tier = $tier
	CustomerId = $customer
	IntegrationGroup = $intGroupName
	IntegrationGroupShort = $intGroupShort
	SharedCustomerGroup = $sharedCustomerGroup
	IntegrationName = $intName
	IntegrationPartitionKey = $partitionKey
}
$processParams = $templateParams + @{
	ConnectionCustomerGroup = "$customer-$conOutGroupName"
	ConnectionType = $conOutType
	ConnectionFunctionApp = $conOutFunctionAppName
	ConnectionCustomerFunctionApp = $conOutFunctionAppLong
	ConnectionFunctionTrigger = $conOutFunctionName
	ConnectionWorkflow = $conOutWorkflowName
	ConnectionPartitionKey = $conOutPartitionKey
	TrFunctionApp = $trFunctionApp
	TrFunctionTrigger = $trFunctionName
	NumConcurrentRuns = $numConcurrentRunsProcess
	MaxWaitingRuns = $numConcurrentWaitingProcess
}
$handlerLogicParams = $templateParams + @{
	BlobContainerPrefix = $archContainerPrefix
	ConnectionCustomerGroup = $sharedCustomerGroup
	ConnectionFunction = 'SftpDownloadAndDeleteFile'
	ConnectionPartitionKey = $conInPartitionKey
	PasswordSecret = $sftpPasswordSecret
	NextCustomerLogicApp = $processCustomerWorkflowName
	NextLogicAppCustomerGroup = $processCustomerGroup
}
$starterParams = $templateParams + @{
	ConnectionCustomerGroup = $sharedCustomerGroup
	ConnectionPartitionKey = $conInPartitionKey
	PasswordSecret = $sftpPasswordSecret
}
$schedulerParams = $templateParams + @{
	TableName = $tableName
	ConnectionInPartitionKey = $conInPartitionKey
	ConnectionOutPartitionKey = $conOutPartitionKey
	LogicAppState = $schedulerWorkflowState
	SplitPartitionKey = $splitPartitionKey
	SplitRowKey = $splitRowKey
	SplitTargetKey = $splitTargetKey
}

# Processing
if ($DeployLogicApp0) {
	$template = if ($processTemplateIdentifier) { "process-$processTemplateIdentifier" } else { 'process' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	Publish-ARMTemplate $templatePath $processParams | Out-Null
}
# Handler
if ($DeployLogicApp1) {
	$templatePath = "$sharedLogicAppRoot\handler-sftp-template.json"
	Publish-ARMTemplate $templatePath $handlerLogicParams | Out-Null
}
# Starter
if ($DeployLogicApp2) {
	$templatePath = "$sharedLogicAppRoot\starter-sftp-template.json"
	Publish-ARMTemplate $templatePath $starterParams | Out-Null
}
# Scheduler - Use additional parameters from file.
if ($DeployLogicApp3) {
	$templatePath = "$sharedLogicAppRoot\scheduler-list-template.json"
	$templateParamPath = "$projectLogicAppRoot\scheduler-parameters-$tier.json"
	Publish-ARMTemplate $templatePath $schedulerParams $templateParamPath | Out-Null
}
