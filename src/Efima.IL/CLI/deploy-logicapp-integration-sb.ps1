param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev',
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp0 = $false,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp1 = $false,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp2 = $false,
	[Parameter(Mandatory=$false)][bool] $DeployLogicApp3 = $false,
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

# Processor
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

# Triggering Starter. Scheduler not needed!
if ($DeployLogicApp2) {
	$starterParams = $templateParams + @{
		ConnectionCustomerGroup = "$eilCustomer-$conInGroupName"
		ConnectionWorkflow = $conInWorkflowName
		ConnectionInPartitionKey = $conInPartitionKey
		ConnectionOutPartitionKey = $conOutPartitionKey
		LogicAppName = $starterWorkflowName
		NextLogicApp = $handlerWorkflowName
		SBAuthenticationType = $serviceBusAuthenticationType
		SBQueueName = $serviceBusQueueName
		SBTopicName = $serviceBusTopicName
		SBSubscriptionName = $serviceBusSubscriptionName
		TableName = $tableName
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

# Polling Starter
if ($DeployLogicApp3) {
	$starterParams = $templateParams + @{
		ConnectionCustomerGroup = "$eilCustomer-$conInGroupName"
		ConnectionPartitionKey = $conInPartitionKey
		LogicAppName = $starterWorkflowName
		NextLogicApp = $handlerWorkflowName
	}

	$template = if ($starterTemplateIdentifier) { "starter-$starterTemplateIdentifier" } else { 'starter' }
	$templatePath = "$sharedLogicAppRoot\$template-template.json"
	Publish-ARMTemplate $templatePath $starterParams | Out-Null
}

# Scheduler (for polling Starter). Use additional parameters from file.
if ($DeployLogicApp4) {
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
