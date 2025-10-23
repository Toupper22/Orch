param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev',
	[Parameter(Mandatory=$false)][bool] $useStarterParameterFile = $false,
	[Parameter(Mandatory=$false)][bool] $DeployProcess = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployHandler = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployStarter = $false,   # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployScheduler = $false, # DEPRECATED
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp0 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp1 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp2 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp3 = $true,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp4 = $false
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

# Processing
if ($DeployLogicApp0) {
	$processParams = $templateParams + @{
		ConnectionCustomerGroup = "$customer-$conOutGroupName"
		ConnectionType = $conOutType
		ConnectionFunctionApp = $conOutFunctionAppName
		ConnectionCustomerFunctionApp = $conOutFunctionAppLong
		ConnectionFunctionTrigger = $conOutFunctionName
		ConnectionWorkflow = $conOutWorkflowName
		ConnectionPartitionKey = $conOutPartitionKey
		ConnectionCustomArguments = $conOutCustomArgs
		TrFunctionTrigger = $trFunctionName
		LogicAppName = $processWorkflowName
		NumConcurrentRuns = $numConcurrentRunsProcess
		MaxWaitingRuns = $numConcurrentWaitingProcess
	}
	$template = if ($processTemplateIdentifier) { "process-$processTemplateIdentifier" } else { 'process' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	Publish-ARMTemplate $templatePath $processParams | Out-Null
}
# Handler
if ($DeployLogicApp1) {
	$handlerParams = $templateParams + @{
		ConnectionCustomerGroup = "$eilCustomer-$conInGroupName"
		BlobContainerPrefix = $archContainerPrefix
		LogicAppName = $handlerWorkflowName
		NextLogicApp = $processWorkflowName
		NextCustomerLogicApp = $processCustomerWorkflowName
		NextLogicAppCustomerGroup = $processCustomerGroup
	}
	$template = if ($handlerTemplateIdentifier) { "handler-$handlerTemplateIdentifier" } else { 'handler' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	Publish-ARMTemplate $templatePath $handlerParams | Out-Null
}
# Starter
if ($DeployLogicApp2) {
	$starterParams = $templateParams + @{
		ConnectionCustomerGroup = "$eilCustomer-$conInGroupName"
		ConnectionWorkflow = $conInWorkflowName
		ConnectionPartitionKey = $conInPartitionKey
		LogicAppName = $starterWorkflowName
		NextLogicApp = $handlerWorkflowName
	}
	$template = if ($starterTemplateIdentifier) { "starter-$starterTemplateIdentifier" } else { 'starter' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	# If I start from the starter instead of scheduler, I need extra parameters in the starter.
	if ($useStarterParameterFile) {
		$templateParamPath = "$projectLogicAppRoot\starter-parameters-$tier.json"
		Publish-ARMTemplate $templatePath $starterParams $templateParamPath | Out-Null
	} else {
		Publish-ARMTemplate $templatePath $starterParams | Out-Null
	}
}
# Scheduler - Use additional parameters from file.
if ($DeployLogicApp3) {
	$schedulerParams = $templateParams + @{
		ConnectionInPartitionKey = if ($conInPartitionSourceKey) { $conInPartitionSourceKey } else { $conInPartitionKey }
		ConnectionOutPartitionKey = if ($conOutPartitionSourceKey) { $conOutPartitionSourceKey } else { $conOutPartitionKey }
		ConnectionInTargetKey = $conInPartitionKey
		ConnectionOutTargetKey = $conOutPartitionKey
		IntegrationTargetKey = $partitionKey
		LogicAppName = $schedulerWorkflowName
		LogicAppState = $schedulerWorkflowState
		NextLogicApp = $starterWorkflowName
		NextCustomerLogicApp = $starterCustomerWorkflowName
		NextLogicAppCustomerGroup = $starterCustomerGroup
		SplitPartitionKey = $splitPartitionKey
		SplitRowKey = $splitRowKey
		SplitPartitionTargetKey = $splitPartitionTargetKey
		SplitTargetKey = $splitTargetKey
		TableName = $tableName
	}
	if ($partitionSourceKey) {
		$schedulerParams.IntegrationPartitionKey = $partitionSourceKey
	}
	$template = if ($schedulerTemplateIdentifier) { "scheduler-$schedulerTemplateIdentifier" } else { 'scheduler' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	$templateParamPath = "$projectLogicAppRoot\scheduler-parameters-$tier.json"
	Publish-ARMTemplate $templatePath $schedulerParams $templateParamPath | Out-Null
}
# 2nd Scheduler
if ($DeployLogicApp4) {
	$scheduler2ndParams = $templateParams + @{
		ConnectionInPartitionKey = if ($conInPartitionSourceKey2nd) { $conInPartitionSourceKey2nd } else { $conInPartitionKey }
		ConnectionOutPartitionKey = if ($conOutPartitionSourceKey2nd) { $conOutPartitionSourceKey2nd } else { $conOutPartitionKey }
		ConnectionInTargetKey = $conInPartitionKey
		ConnectionOutTargetKey = $conOutPartitionKey
		IntegrationTargetKey = $partitionKey
		LogicAppName = if ($schedulerWorkflowName2nd) { $schedulerWorkflowName2nd } else { 'scheduler2nd' }
		LogicAppState = $schedulerWorkflowState
		NextLogicApp = $starterWorkflowName
		NextCustomerLogicApp = $starterCustomerWorkflowName
		NextLogicAppCustomerGroup = $starterCustomerGroup
		SplitPartitionKey = $splitPartitionKey2nd
		SplitRowKey = $splitRowKey2nd
		SplitPartitionTargetKey = $splitPartitionTargetKey
		SplitTargetKey = $splitTargetKey
		TableName = if ($tableName2nd) { $tableName2nd } else { $tableName }
	}
	if ($partitionSourceKey2nd) {
		$scheduler2ndParams.IntegrationPartitionKey = $partitionSourceKey2nd
	}
	$templatePath = "$sharedLogicAppRoot\scheduler-list-template.json"
	$templateParamPath = "$projectLogicAppRoot\scheduler-parameters-$tier.json"
	Publish-ARMTemplate $templatePath $scheduler2ndParams $templateParamPath | Out-Null
}
