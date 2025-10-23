param(
    [Parameter(Mandatory=$false)]
    [string]$location = "westeurope",

    [Parameter(Mandatory=$true)]
    [string]$tier = "dev",

    [Parameter(Mandatory=$false)]
    [string]$publisherEmail,

    [Parameter(Mandatory=$false)]
    [string]$publisherName,

    [Parameter(Mandatory=$false)]
    [string]$sharedKeyvaultName,

    [Parameter(Mandatory=$false)]
    [string]$skuCount = "1",

    # add other needed parameters as required
    [Parameter(Mandatory=$false)]
    [string]$tags = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet('Developer', 'Standard', 'Premium')]
    [string]$skuName = "Developer"

)


try {
    . .\deploy-commonvariables.ps1 -tier $tier
    Write-Host "Variables loaded successfully"
} catch {
    Write-Error "Failed to load variables: $_"
    exit 1
}

try {
    Set-DefaultLocation $location
    Write-Host "Location set to: $location"
} catch {
    Write-Error "Failed to set location: $_"
    exit 1
}

# Set resource group.
Set-DefaultResourceGroup $targetResourceGroup

# Map tier to APIM SKU
$skuName = switch ($tier.ToLower()) {
    'dev' { 'Developer' }
    'test' { 'Basic' }
    'prod' { 'Basic' }
    default { 'Developer' }
}

# Set up tags
$tags = @{
    Service = "APIM"
    CreatedBy = "Infrastructure Pipeline"
    Project = $customer
}

# Deploy Bicep template
$deploymentName = "apim-$customer$(Get-Date -Format 'yyyyMMddHHmm')"

# Prepare Parameters
$parameters = @{
    sharedApimName = $sharedApimName
    publisherEmail = $publisherEmail
    publisherName = $publisherName
    publicIpName = $apimPublicIpName
    sharedKeyvaultName = $sharedKeyvaultName
    skuName = $skuName
    skuCount = $skuCount
    location = $location

}

$testResult = Test-BicepDeployment `
    -DeploymentName "test-deployment" `
    -ResourceGroup $targetResourceGroup `
    -TemplateFilePath "$PSScriptRoot/deploy-apim.bicep" `
    -Parameters $parameters

if ($testResult) {
    Write-Host "Test passed, proceeding with deployment"
    Publish-BicepTemplate `
    -DeploymentName $deploymentName `
    -ResourceGroup $targetResourceGroup `
    -TemplateFilePath "$PSScriptRoot/deploy-apim.bicep" `
    -Parameters $parameters
} else {
    Write-Error "Test failed, aborting deployment"
    exit 1
}