param(
	[Parameter(Mandatory=$true)][String] $customer,
	[Parameter(Mandatory=$true)][String] $tier = "dev"
)

# Load variables and scripts.
if (!$targetResourceGroup) {
	. .\deploy-commonvariables.ps1 -customer $customer -tier $tier

	Set-DefaultResourceGroup $targetResourceGroup
}

# public ip - required for static ip
$publicIp = "pip-${customer}-${intGroupName}-$tier"
$publicIpDnsPrefix = $null
$publicIpIdleTimeout = 10
$publicIpAllocationMethod = "Static" #"Static"/"Dynamic"
$publicIpSku = "Standard" # "Standard" / "Basic"
Publish-PublicIp $targetResourceGroup $publicIp $publicIpDnsPrefix $publicIpIdleTimeout $publicIpAllocationMethod $publicIpSku

# nat gateway - required for static ip
$natGatewayPublicIps = @(
	$publicIp
)
$natGatewayIdleTimeout = 10
Publish-NatGateway $targetResourceGroup $targetNatGateway $natGatewayPublicIps $natGatewayIdleTimeout

# vnet - required for static ip
$vnetIpAddressPrefixes = @(
	"10.0.0.0/16"
)
Publish-Vnet $targetResourceGroup $targetVnetName $vnetIpAddressPrefixes

# subnet - required for static ip
$subnetIpAddressPrefixes = @(
	"10.0.0.0/24"
)
Publish-Subnet $targetResourceGroup $targetVnetName $targetSubnetName $subnetIpAddressPrefixes $targetNatGateway
