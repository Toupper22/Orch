param(
	[Parameter(Mandatory=$false)][String] $customer,
	[Parameter(Mandatory=$false)][String] $intName = 'na',
	[Parameter(Mandatory=$false)][String] $tier = 'dev'
)

. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

Set-DefaultResourceGroup $targetResourceGroup

# Assume template path is in a variable.
$templatePath = "$sharedLogicAppRoot\$logicAppTemplateIdentifier-template.json"
$templateParams = $logicAppParams + @{
	Tier = $tier
	CustomerId = $customer
	IntegrationGroup = $intGroupName
	IntegrationGroupShort = $intGroupShort
	IntegrationName = $intName
	SharedCustomerGroup = $sharedCustomerGroup
}
Publish-ARMTemplate $templatePath $templateParams