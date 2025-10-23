
function Confirm-Error()
{
    if ($LastExitCode -ne 0) {
        Throw $LastExitCode 
    }
}

function Set-AzureSubscription([String] $accountName)
{
    Write-Host "Setting Azure Subscription to $accountName"
    
    az account set -s $accountName
    Confirm-Error
    
    Write-Host "Azure Subscription set to $accountName"
}

function Set-DefaultLocation([String] $location)
{
    Write-Host "Setting Location $location as default"

    az configure --defaults location=$location
    Confirm-Error

    Write-Host "Location $location set as default"
}

function Set-DefaultResourceGroup([String] $resourceGroup)
{
    Write-Host "Setting ResourceGroup $resourceGroup as default"

    az configure --defaults group=$resourceGroup
    Confirm-Error

    Write-Host "ResourceGroup $resourceGroup set as default"
}

function Publish-ResourceGroup([String] $resourceGroup)
{
    Write-Host "ResourceGroup $resourceGroup publish started"

    $resourceGroupExists = az group exists -n $resourceGroup
    if ($resourceGroupExists -eq $false) {
        Write-Host "ResourceGroup $resourceGroup does not exist, creating"
        
        if ($useTags -eq $true) {
            $tagParams = $tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
            az group create -n $resourceGroup --tags $tagParams
        }
        else {
            az group create -n $resourceGroup
        }
        Confirm-Error

        Write-Host "ResourceGroup $resourceGroup created"
    }
    else
    {
        Write-Host "ResourceGroup $resourceGroup already exists, skipping"
    }

    # Assign Contributor role for development purposes. Note that the service connection needs
    # a permission to assign roles. Suitable only in subscriptions where the service connection
    # is trusted and can't be abused.
    if (-not ($devgroup -eq $null -or $devgroup -eq ""))
    {
        $contributorRoleId = az role definition list --name "Contributor" --query "[].{id:id}" --output tsv
        az role assignment create --assignee "$devgroup" `
            --role "$contributorRoleId" `
            --resource-group "$resourceGroup"
        # Error checking not applied. Script will continue if failed.
    }
}

function Publish-KeyVault([String] $KeyvaultName, [String] $tier)
{
    Write-Host "KeyVault $KeyvaultName publish started"
    
    # Key vault: Conditional deployment (avoid resetting keyvault access policy with every deployment)
    az keyvault show --name $KeyvaultName -o none
    if ($LastExitCode -ne 0) {
        Write-Host "KeyVault $KeyvaultName does not exist, creating"

        $enablePurgeProtection = false
        if ($tier -eq "prod") {
            $enablePurgeProtection = true
        }

        az keyvault create --name $KeyvaultName `
            --enabled-for-template-deployment true `
            --enable-purge-protection $enablePurgeProtection `
            --enable-rbac-authorization false
        Confirm-Error

        Write-Host "KeyVault $KeyvaultName created with purge protection set to $enablePurgeProtection"
    }
    else
    {
        Write-Host "KeyVault $KeyvaultName already exists, skipping"
    }
    
    #Set secret permissions to KeyVault
    if($secretPermissionObjectIds -ne $null)
    {
        ForEach ($objectId in $secretPermissionObjectIds)
        {
            Write-Host "Setting KeyVault secret permissions for $objectId"

            az keyvault set-policy --name $KeyvaultName --object-id $objectId --secret-permissions get set list delete
            Confirm-Error

            Write-Host "KeyVault secret permissions set for $objectId"
        }
    }
}

function Publish-ApplicationInsights([String] $appInsightsName, [String] $location, [String] $logAnalyticsWorkspaceName, [String] $resourceGroup) {
    Write-Host "AppInsights $appInsightsName publish started" -ForegroundColor green

    # Application Insights: Conditional deployment
    try 
    {
        az extension add --name application-insights

        $appInsightsStatus = az monitor app-insights component show --app $appInsightsName -g $resourceGroup
        if(($appInsightsStatus -eq $null) -or ($appInsightsStatus -eq ""))
        {
            $appInsightsExists = $false
	    }
        else
        {
            $appInsightsExists = $true
	    }
    }
    catch
    {
        $appInsightsExists = $false
    }

    if ($appInsightsExists -eq $false)
    {
        Write-Host "AppInsights $appInsightsName does not exist, creating"
        
        az extension add --name application-insights
        az monitor app-insights component create --app $appInsightsName --location $location --kind web -g $resourceGroup --workspace $logAnalyticsWorkspaceName
        Confirm-Error

        Write-Host "AppInsights $appInsightsName created"
    }
    else
    {
        Write-Host "AppInsights $appInsightsName already exists, skipping"
    }
}

function Publish-LogAnalyticsWorkspace([String] $logAnalyticsWorkspaceName, [String] $resourceGroup) {
    Write-Host "LogAnalyticsWorkspace $logAnalyticsWorkspaceName publish started" -ForegroundColor green
    # Log Analytics workspace: Conditional deployment
    try 
    {
        $logAnalyticsStatus = az monitor log-analytics workspace show --resource-group $resourceGroup --workspace-name $logAnalyticsWorkspaceName

        if(($logAnalyticsStatus -eq $null) -or ($logAnalyticsStatus -eq ""))
        {
            $logAnalyticsExists = $false
	    }
        else
        {
            $logAnalyticsExists = $true
	    }
    }
    catch
    {
        $logAnalyticsExists = $false
    }

    if ($logAnalyticsExists -eq $false)
    {
        Write-Host "LogAnalyticsWorkspace $logAnalyticsWorkspaceName does not exist, creating"
        az monitor log-analytics workspace create --resource-group $resourceGroup --workspace-name $logAnalyticsWorkspaceName
        Confirm-Error

        Write-Host "LogAnalyticsWorkspace $logAnalyticsWorkspaceName created"
    }
    else
    {
        Write-Host "LogAnalyticsWorkspace $logAnalyticsWorkspaceName already exists, skipping"
    }
}

function Publish-LogAnalyticsLogicAppsManagement([String] $logAnalyticsName, [String] $resourceGroup) {
    Write-Host "LogAnalytics workspace $logAnalyticsName solution LogicAppsManagement publish started"

    # LogAnalyticsWorkspace: Conditional deployment
    try 
    {
        az extension add --name log-analytics-solution
        $solutionName = -join("LogicAppsManagement(", $logAnalyticsName, ")")

        $logAnalyticsStatus = az monitor log-analytics solution show -g $resourceGroup -n $solutionName
        if(($logAnalyticsStatus -eq $null) -or ($logAnalyticsStatus -eq ""))
        {
            $logAnalyticsExists = $false
	    }
        else
        {
            $logAnalyticsExists = $true
	    }
    }
    catch
    {
        $logAnalyticsExists = $false
    }

    if ($logAnalyticsExists -eq $false)
    {
        Write-Host "LogAnalytics workspace $logAnalyticsName solution LogicAppsManagement does not exist, creating"

        az monitor log-analytics solution create -g $resourceGroup -w $logAnalyticsName -t LogicAppsManagement 
        Confirm-Error

        Write-Host "LogAnalytics $logAnalyticsName solution LogicAppsManagement created"
    }
    else
    {
        Write-Host "LogAnalytics $logAnalyticsName solution LogicAppsManagement already exists, skipping"
    }
}


function Get-StorageAccountExists([String] $accountName)
{
    try
    {
        $fnStorageAccountStatus = az storage account show -n $accountName
        Confirm-Error

        if($fnStorageAccountStatus -eq $null -or $fnStorageAccountStatus -eq "")
        {
            return $false
	    }
        else
        {
            return $true
	    }
    } 
    catch
    {
        return $false
    }
}

function Get-StorageContainerExists([String] $accountName, [String] $containerName)
{
    $storageContainerCheck = az storage container exists --account-name $accountName --name $containerName --auth-mode login -o tsv
    Confirm-Error
    return $storageContainerCheck
}

function Get-StorageTableExists([String] $accountName, [String] $tableName)
{
    $storageTableCheck = az storage table exists --account-name $accountName --name $tableName --auth-mode login -o tsv
    Confirm-Error
    return $storageTableCheck
}

function Get-StorageQueueExists([String] $accountName, [String] $queueName)
{
    $storageQueueCheck = az storage queue exists --account-name $accountName --name $queueName --auth-mode login -o tsv
    Confirm-Error
    return $storageQueueCheck
}

function Publish-StorageAccount
{
    Param
    (
        [Parameter(Mandatory=$true)][string]  $AccountName,
        [Parameter(Mandatory=$false)][string] $KeyvaultName,
        [Parameter(Mandatory=$false)][string] $KeyvaultSecretName,
        [Parameter(Mandatory=$false)][string] $PolicyFile = $null,
        [Parameter(Mandatory=$false)][bool]   $SecureStorage = $false,
        [Parameter(Mandatory=$false)][bool]   $EnableSftp = $false
    )

    Write-Host "##[group]StorageAccount $AccountName publish started"

    Write-Host "Checking if storage account $AccountName exists"
    $storageExists = Get-StorageAccountExists $AccountName

    if ($storageExists -ne $true) 
    {
        Write-Host "##[section]Storage account '$AccountName' does not exist exists, creating"
        
        if ($EnableSftp)
        {
            # SFTP support requires hierarchical namespace to be enabled
            # This requires a separate upgrade process for existing accounts, only works here for new accounts
            # See https://learn.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support and associated articles for more info
            az storage account create -n $AccountName --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2 --enable-hierarchical-namespace true
            Confirm-Error

            Write-Host "Enabling SFTP on storage account '$AccountName'"
            az storage account update -n $AccountName --enable-sftp true
            Confirm-Error
        }
        else
        {
            az storage account create -n $AccountName --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2
            Confirm-Error
        }

        Write-Host "Storage account '$AccountName' created"
    } 
    else 
    {
        Write-Host "##[warning]Storage account '$AccountName' already exists, skipping"
    }
    if ($SecureStorage)
    {
        Write-Host "Temporarily allow access to secure storage."

        # Allow access temporarily in order to be able to e.g. create containers. See Configure-SecureStorage.
        az storage account update --name $AccountName --bypass AzureServices --default-action Allow
        Confirm-Error

        Write-Host "Waiting 50 seconds."
        Start-Sleep -Seconds 50
    }
    if ($PolicyFile)
    {
        Write-Host "##[section]Setting up Storage Account '$AccountName' management policy from file $PolicyFile"

        az storage account management-policy create --policy $PolicyFile --account-name $AccountName
        Confirm-Error

        Write-Host "Storage Account '$AccountName' management policy set."
    }

    if (-not ([string]::IsNullOrEmpty($KeyvaultName) -or [string]::IsNullOrEmpty($KeyvaultSecretName)))
    {
        Write-Host "##[section]Setting up Storage Account '$AccountName' secret '$KeyvaultSecretName' to keyvault '$KeyvaultName'."

        $storageConnectionString = az storage account show-connection-string -n $AccountName -o tsv
        Confirm-Error
        Update-KeyvaultSecretValue-IfDifferent `
            -KeyvaultName $KeyvaultName `
            -KeyvaultSecretName $KeyvaultSecretName `
            -Value $storageConnectionString
        Confirm-Error

        Write-Host "Storage Account '$AccountName' secret '$KeyvaultSecretName' to keyvault '$KeyvaultName' set."
    }

    Write-Host "##[endgroup]"
}

function Get-SftpUserExists([String] $accountName, [String] $username, [String] $resourceGroup)
{
    try
    {
        $userInfo = az storage account local-user show --account-name $accountName --name $username --resource-group $resourceGroup
        Confirm-Error

        if($userInfo -eq $null -or $userInfo -eq "")
        {
            return $false
	    }
        else
        {
            return $true
	    }
    } 
    catch
    {
        return $false
    }
}

function Create-SftpUser([String] $accountName, [String] $username, [String] $resourceGroup)
{
    $userExists = Get-SftpUserExists -accountName $accountName -username $username -resourceGroup $resourceGroup
    if ($userExists -eq $false) {
        Write-Host "Creating SFTP user '$username' in storage account '$accountName'."
        az storage account local-user create --account-name $accountName `
            --resource-group $resourceGroup `
            --name $username `
            --has-ssh-password true `
            | Out-Null
        Confirm-Error
    }
    else {
        Write-Host "SFTP user '$username' already exists in storage account '$accountName'."
    }
}

function Set-SftpUserPermissions([String] $accountName, [String] $username, [String] $containerName, [String] $permissions, [String] $resourceGroup)
{
    # Permissions = some combination of r (read), w (write), d (delete), l (list), c (create)
    Write-Host "Setting permissions for SFTP user '$username' in storage account '$accountName' to container '$containerName'."
    az storage account local-user update --account-name $accountName `
        --resource-group $resourceGroup `
        --name $username `
        --home-directory $containerName `
        --permission-scope permissions=$permissions service=blob resource-name=$containerName `
        | Out-Null
    Confirm-Error
}

function Publish-ServiceBusQueues
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Namespace,
        [Parameter(Mandatory=$true)]
        [String[]] $QueueNames,
        [Parameter(Mandatory=$false)]
        [String] $ResourceGroup
    )

    $additionalParams = @()
    # if $ResourceGroup is not specified, current will be used in this context
    if (-not ([String]::IsNullOrEmpty($ResourceGroup)))
    {
        $additionalParams += "--resource-group", $ResourceGroup
    }
    
    Write-Host "##[group]Service bus namespace '$Namespace' queues publish"

    if ($QueueNames -ne $null)
    {
        # query existing queues list
        $existingQueues = ( az servicebus queue list --namespace-name $Namespace $additionalParams `
            | ConvertFrom-Json )`
            | Select-Object -ExpandProperty name
        $existingQueues

        ForEach ($queueName in $QueueNames)
        {
            Write-Host "Checking if queue '$queueName' exists"

            if ($queueName -in $existingQueues) 
            {
                Write-Host "Queue '$queueName' already exists, no action"
            } 
            else
            {
                Write-Host "Queue '$queueName' does not exist, creating"
        
                az servicebus queue create `
	                --name $queueName `
                    --namespace-name $Namespace `
                    $additionalParams
                Confirm-Error

                Write-Host "Queue '$queueName' created"
            }
        }
    }
    else
    {
        Write-Host "Queue list empty"
    }

    Write-Host "##[endgroup]"
}

function Publish-ServiceBusTopics
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Namespace,
        [Parameter(Mandatory=$true)]
        [String[]] $TopicNames,
        [Parameter(Mandatory=$false)]
        [String] $ResourceGroup
    )

    $additionalParams = @()
    # if $ResourceGroup is not specified, current will be used in this context
    if (-not ([String]::IsNullOrEmpty($ResourceGroup)))
    {
        $additionalParams += "--resource-group", $ResourceGroup
    }
    
    Write-Host "##[group]Service bus namespace '$Namespace' topics publish"

    if ($TopicNames -ne $null)
    {
        # query existing topics list
        $existingTopics = ( az servicebus topic list --namespace-name $Namespace $additionalParams `
            | ConvertFrom-Json )`
            | Select-Object -ExpandProperty name
        $existingTopics

        ForEach ($topicName in $TopicNames)
        {
            Write-Host "Checking if topic '$topicName' exists"

            if ($topicName -in $existingTopics) 
            {
                Write-Host "Topic '$topicName' already exists, no action"
            } 
            else
            {
                Write-Host "Topic '$topicName' does not exist, creating"
        
                az servicebus topic create `
	                --name $topicName `
                    --namespace-name $Namespace `
                    $additionalParams
                Confirm-Error

                Write-Host "Topic '$topicName' created"
            }
        }
    }
    else
    {
        Write-Host "Topic list empty"
    }

    Write-Host "##[endgroup]"
}

function Publish-ServiceBusTopicSubscriptions
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Namespace,
        [Parameter(Mandatory=$true)]
        [String[]] $TopicName,
        [Parameter(Mandatory=$true)]
        [String[]] $TopicSubscriptionNames,
        [Parameter(Mandatory=$false)]
        [String] $ResourceGroup
    )

    $additionalParams = @()
    # if $ResourceGroup is not specified, current will be used in this context
    if (-not ([String]::IsNullOrEmpty($ResourceGroup)))
    {
        $additionalParams += "--resource-group", $ResourceGroup
    }
    
    Write-Host "##[group]Service bus namespace '$Namespace' topic '$TopicName' subscriptions publish"

    if ($TopicSubscriptionNames -ne $null)
    {
        # query existing topics list
        $existingTopicSubscriptions = ( az servicebus topic subscription list --namespace-name $Namespace --topic-name $TopicName $additionalParams `
            | ConvertFrom-Json )`
            | Select-Object -ExpandProperty name
        $existingTopicSubscriptions

        ForEach ($topicSubscriptionName in $TopicSubscriptionNames)
        {
            Write-Host "Checking if topic subscription '$topicSubscriptionName' exists"

            if ($topicSubscriptionName -in $existingTopicSubscriptions) 
            {
                Write-Host "Topic subscription '$topicSubscriptionName' already exists, no action"
            } 
            else
            {
                Write-Host "Topic subscription '$topicSubscriptionName' does not exist, creating"
        
                az servicebus topic subscription create `
	                --name $topicSubscriptionName `
                    --namespace-name $Namespace `
	                --topic-name $topicName `
                    $additionalParams
                Confirm-Error

                Write-Host "Topic subscription '$topicSubscriptionName' created"
            }
        }
    }
    else
    {
        Write-Host "Topic subscription list empty"
    }

    Write-Host "##[endgroup]"
}

function Publish-StorageContainers([String] $accountName, [String[]] $containerNames)
{
    
    if($containerNames -ne $null)
    {
        ForEach ($container in $containerNames)
        {
            Write-Host "Checking if storage account $accountName container $container exists"
            $containerExists = Get-StorageContainerExists $accountName $container

            if ($containerExists -ne $true) 
            {
                Write-Host "Storage account '$accountName' container '$container' does not exist, creating"
        
                az storage container create --n $container --account-name $accountName
                Confirm-Error

                Write-Host "Storage account '$accountName' container '$container' created"
            } 
            else 
            {
                Write-Host "Storage account '$accountName' container '$container' already exists, skipping"
            }
        }
    }
}

function Publish-StorageTables([String] $accountName, [String[]] $tableNames)
{
    Write-Host "StorageAccount $accountName tables publish started"
    
    if($tableNames -ne $null)
    {
        ForEach ($tableName in $tableNames)
        {
            Write-Host "Checking if storage account $accountName table $tableName exists"
            $tableExists = Get-StorageTableExists $accountName $tableName

            if ($tableExists -ne $true) 
            {
                Write-Host "Storage account '$accountName' table '$tableName' does not exist, creating"
        
                az storage table create --n $tableName --account-name $accountName
                Confirm-Error

                Write-Host "Storage account '$accountName' table '$tableName' created"
            } 
            else 
            {
                Write-Host "Storage account '$accountName' table '$tableName' already exists, skipping"
            }
        }
    }
}

function Insert-TableEntities([String] $accountName, [String] $tableName, [String] $partitionKey, [hashtable] $keysAndValues, [String] $propertyName = $null)
{
    Write-Host "Insert entities to table '$tableName'. Partition key '$partitionKey'."

    foreach ($kv in $keysAndValues.GetEnumerator())
    {
        $k = $kv.key
        $v = $kv.value
        if ($v -is [boolean])
        {
            $type = 'Edm.Boolean'
        }
        elseif ($v -is [int])
        {
            $type = 'Edm.Int32'
        }
        elseif ($v -is [double])
        {
            $type = 'Edm.Double'
        }
        else
        {
            $type = 'Edm.String'
        }

        Write-Host "$k = $v $type"

        if ($propertyName)
        {
            az storage entity insert --table-name $tableName --account-name $accountName --if-exists fail --entity PartitionKey=$partitionKey RowKey=$tableRowKey PropertyName=$propertyName Key=$k Value=$v Value@odata.type=$type
            $tableRowKey++
        }
        else
        {
            az storage entity insert --table-name $tableName --account-name $accountName --if-exists fail --entity PartitionKey=$partitionKey RowKey=$k Value=$v Value@odata.type=$type
        }
    }
}

function Insert-TableEntitiesErrors([String] $accountName, [String] $tableName, [String] $partitionKey, [hashtable] $rowKeysAndValues)
{
    Write-Host "Insert entities to table '$tableName'. Partition key '$partitionKey'."

    foreach ($kv in $rowKeysAndValues.GetEnumerator())
    {
        $rowKey = $kv.key
        $hashtableValue = $kv.value
        
        Write-Host "Processing rowKey = $rowKey"

        # Accessing values from the hashtable
        $contains = $hashtableValue["Contains"]
        $containsType = $hashtableValue["ContainsType"]
        $disableBundling = $hashtableValue["DisableBundling"]
        $disableBundlingType = $hashtableValue["DisableBundlingType"]
        $message = $hashtableValue["Message"]
        $messageType = $hashtableValue["MessageType"]
        $regex = $hashtableValue["Regex"]
        $regexType = $hashtableValue["RegexType"]

        try
        {
            # Insert the entire entity at once
            Write-Host "Inserting entity"
            az storage entity insert --table-name $tableName --account-name $accountName  `
            --entity PartitionKey=$partitionKey `
                     RowKey=$rowKey  `
                     Contains=$contains `
                     ContainsType=$containsType `
                     DisableBundling=$disableBundling `
                     DisableBundlingType=$disableBundlingType `
                     Message=$message `
                     MessageType=$messageType `
                     Regex=$regex `
                     RegexType=$regexType `
            --if-exists merge

            Confirm-Error
            Write-Host "Successfully inserted entity for rowKey = $rowKey"
        }
        catch
        {
            Write-Host "Error inserting entity for rowKey = $rowKey." -ForegroundColor Red
        }
    }
}

function Publish-StorageQueues([String] $accountName, [String[]] $queueNames)
{
    Write-Host "StorageAccount $accountName queues publish started"
    
    if($queueNames -ne $null)
    {
        ForEach ($queueName in $queueNames)
        {
            Write-Host "Checking if storage account $accountName queue $queueName exists"
            $queueExists = Get-StorageQueueExists $accountName $queueName

            if ($queueExists -ne $true) 
            {
                Write-Host "Storage account '$accountName' queue '$queueName' does not exist, creating"
        
                az storage queue create --n $queueName --account-name $accountName
                Confirm-Error

                Write-Host "Storage account '$accountName' queue '$queueName' created"
            } 
            else 
            {
                Write-Host "Storage account '$accountName' queue '$queueName' already exists, skipping"
            }
        }
    }
}

function Publish-AlertRuleV2([String] $templateFilePath, [String] $parameterFilePath, [hashtable] $alertRuleEnabledOnTier = $null)
{
    $inlineParameters = @{
        Tier = $tier
        CustomerId = $customer
    }
    if ($alertRuleEnabledOnTier -ne $null)
    {
        $tmpString = $alertRuleEnabledOnTier.$tier
        $inlineParameters.Add('AlertEnabled', $tmpString)
    }
    Publish-ARMTemplate $templateFilePath $inlineParameters $parameterFilePath
}

function Publish-ARMTemplate([String] $templateFilePath, [hashtable] $inlineParameters, [String] $parameterFilePath = $null)
{
    Write-Host 'ARM template deployment started.'
    Write-Host "Template file: $templateFilePath"
    Write-Host "Inline parameters: $inlineParameters"

    [System.Collections.ArrayList]$inlParamArray = @()
    foreach($kv in $inlineParameters.GetEnumerator())
    {
        Write-Host "$($kv.key)=$($kv.value)"
        if ($kv.value -ne $null) {
            $inlParamArray.Add("$($kv.key)=$($kv.value)")
        }
        else {
            Write-Host 'Drop since null.'
        }
    }

    $retries = 0
    $maxCount = 5
    do
    {
        try
        {
            if($parameterFilePath)
            {
                Write-Host "Parameter file: $parameterFilePath"
                $deployedTemplate = az deployment group create --template-file $templateFilePath --parameters $parameterFilePath --parameters @inlParamArray
            }
            else
            {
                $deployedTemplate = az deployment group create --template-file $templateFilePath --parameters @inlParamArray
            }
            Confirm-Error
            Write-Host "ARM template $templateFilePath deployed."
            break
        }
        catch
        {
            $retries++
        }
    } while($retries -lt $maxCount)

    if($retries -ge $maxCount)
    {
        Throw $LastExitCode
    }

    $deployedTemplate
}

function Delete-ARMResource([String] $resourceGroupName, [String] $resourceType, [String] $resourceName)
{
    Write-Host "Deletion of ARM resource started."
    Write-Host "Resource Group: $resourceGroupName"
    Write-Host "Resource Type: $resourceType"
    Write-Host "Resource Name: $resourceName"

    $retries = 0
    $maxCount = 5
    do
    {
        try
        {
            # If the resource is not present, the Azure CLI command az resource delete will not throw an error but will return a message indicating that
            # the resource could not be found or does not exist.
            $deleteResponse = az resource delete --resource-group $resourceGroupName --resource-type $resourceType --name $resourceName
            Confirm-Error
            Write-Host "Resource $resourceName of type $resourceType deleted successfully. Response: $deleteResponse"
            break
        }
        catch
        {
            $retries++
            Write-Host "Attempt $retries of $maxCount failed. Retrying..."
        }
    } while ($retries -lt $maxCount)

    if ($retries -ge $maxCount)
    {
        Throw "Failed to delete the resource after $maxCount attempts."
    }

    $deleteResponse
}

function DeployZip([String] $functionAppName, [String] $zipPath, [String] $slotName)
{
    Write-Host "Start Function app '$functionAppName' zip deployment to slot $slotName"

	$retries = 0
	$maxCount = 5

	do
    {
		try
        {
            if($slotName -eq $null -or $slotName -eq "") { az functionapp deployment source config-zip -n $functionAppName --src $zipPath -t 600 }
			else { az functionapp deployment source config-zip -n $functionAppName --src $zipPath -t 600 -s $slotName }
			Confirm-Error
			Write-Host "Function app '$functionAppName' zip deployed to slot $slotName"
			break
		}
		catch
        {
			$retries++
		}
	}while($retries -lt $maxCount)
	
    if($retries -ge $maxCount)
    {
        Throw $LastExitCode
	}
}

function SwapDeploymentSlotToProduction([String] $functionAppName, [String] $sourceSlotName)
{
	$retries = 0
	$maxCount = 5

	do
    {
		try
        {
            Write-Host "Swapping deployment slot $sourceSlotName to production for function app $functionAppName"
            
            az functionapp deployment slot swap -n $functionAppName -s $sourceSlotName --target-slot production
            Confirm-Error

            Write-Host "Swapping deployment slot $sourceSlotName to production for function app $functionAppName completed"
			break
		}
		catch
        {
			$retries++
		}
	}while($retries -lt $maxCount)
	
    if($retries -ge $maxCount)
    {
        Throw $LastExitCode
	}
}

function Publish-FunctionApp
{
    Param
    (
        [Parameter(Mandatory=$true)][string]   $FunctionAppName,
        [Parameter(Mandatory=$true)][string]   $FuncStorageName,
        [Parameter(Mandatory=$true)][string]   $KeyvaultName,
        [Parameter(Mandatory=$true)][string]   $ZipPath,
        [Parameter(Mandatory=$true)][string[]] $AppSettings,
        [Parameter(Mandatory=$false)][string]  $PolicyFile = $null,
        [Parameter(Mandatory=$false)][bool]    $SecureStorage = $false,
        [Parameter(Mandatory=$false)][bool]    $UseSharedVnet = $false,
        [Parameter(Mandatory=$false)]          $ForceOutboundTrafficToVnet = $null,
        [Parameter(Mandatory=$false)][bool]    $ForceConfigureSecurity = $false,
        [Parameter(Mandatory=$false)][bool]    $useDeploymentSlot = $false,
        [Parameter(Mandatory=$false)][string]  $taskHubName = "",
        [Parameter(Mandatory=$false)][bool]    $UseApplicationInsights = $true,
        [Parameter(Mandatory=$false)][string]  $AppServicePlan = "",
        [Parameter(Mandatory=$false)][string]  $IdentityId = $null
    )

    Write-Host "##[group]Function App '$FunctionAppName' publish started"

    # Application Insights key
    if ($UseApplicationInsights)
    {
        $appInsightsKey = (az resource show -g $sharedResourceGroup -n $appInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json).properties.InstrumentationKey
    }

    # Create function app from scratch if it does not exist
    try
    {
        # use default resource group
        $functionAppPlan = az functionapp show -n $FunctionAppName --query appServicePlanId -o tsv
        if (($functionAppPlan -eq $null) -or ($functionAppPlan -eq ""))
        {
            $functionAppExists = $false
        }
        else
        {
            $functionAppExists = $true
        }
    } 
    catch 
    {
        $functionAppExists = $false
    }

    if ($functionAppExists -eq $false)
    {
        # Create function app
        Write-Host "##[section]FunctionApp '$FunctionAppName' does not exist. Create a storage first."

        # Function app storage
        Publish-StorageAccount -AccountName $FuncStorageName `
            -KeyvaultName $KeyvaultName `
            -PolicyFile $PolicyFile `
            -SecureStorage $false `
        | Out-Null

        # Storage Vnet
        if ($UseSharedVnet) {
            Configure-StorageVnet -AccountName $FuncStorageName | Out-Null
        }

        # Storage security
        if ($SecureStorage)
        {
            Configure-SecureStorage -AccountName $FuncStorageName | Out-Null
        }

        # Create function app
        Write-Host "##[section]FunctionApp '$FunctionAppName' about to be created."

        $params = "--name", $FunctionAppName
        $params += "--storage-account", $FuncStorageName
        if ([string]::IsNullOrEmpty($AppServicePlan))
        {
            $params += '--consumption-plan-location', $location
        }
        else
        {
            Write-Host "##[section]FunctionApp Using existing plan '$AppServicePlan'."
            $params += "--plan", $AppServicePlan
        }

        # Add VNet parameters during creation if VNet integration is needed
        if ($UseSharedVnet) {
            $params += "--vnet", "/subscriptions/$sharedSubscriptionId/resourceGroups/$sharedResourceGroup/providers/Microsoft.Network/virtualNetworks/$sharedVnetName"
            $params += "--subnet", $sharedSubnetName
        } else {
            $params += "--configure-networking-later", "true"
        }
        
        $params += "--app-insights-key", $appInsightsKey
        $params += "--runtime", "dotnet"
        $params += "--functions-version", $functionsVersion
        $params += '--https-only', 'true'
        az functionapp create @params
        Confirm-Error

        # Assign identity.
        if ($IdentityId)
        {
            Write-Host "##[section]FunctionApp Assign identity '$IdentityId'."
            az functionapp identity assign -n $FunctionAppName --identities $IdentityId
            Confirm-Error

            # This is needed for keyvault referencing environment variables to work.
            az functionapp update -n $FunctionAppName --set keyVaultReferenceIdentity=$IdentityId
            Confirm-Error
        }
        else
        {
            Write-Host "##[section]FunctionApp Create & assign identity."
            az functionapp identity assign -n $FunctionAppName
            Confirm-Error

            $principalId = az functionapp identity show -n $FunctionAppName --query principalId -o tsv
            Confirm-Error

            #Set keyvault rights. Keyvault is supposed to be in the same resource group.
            Write-Host "##[section]FunctionApp Set KeyVault rights."
            az keyvault set-policy -n $KeyvaultName --object-id $principalId --secret-permissions get
            Confirm-Error
            Write-Host "##[section]FunctionApp KeyVault rights set."
        }
    }
    else
    {
        if ($ForceConfigureSecurity)
        {
            if ($UseSharedVnet)
            {
                Configure-StorageVnet -AccountName $FuncStorageName | Out-Null
            }
            if ($SecureStorage)
            {
                Configure-SecureStorage -AccountName $FuncStorageName | Out-Null
            }
            if ($UseSharedVnet)
            {
                Configure-FunctionAppVnet -FunctionAppName $FunctionAppName `
                    -VnetName $sharedVnetName `
                    -SubnetName $sharedSubnetName `
                    -RgName $sharedResourceGroup `
                    -ForceOutboundTrafficToVnet $ForceOutboundTrafficToVnet | Out-Null
            }
        }

        if([String]::IsNullOrEmpty($appServicePlan))
        {
            Write-Host "##[section]FunctionApp '$FunctionAppName' exists and no plan given. Skipping."
        }
        elseif($appServicePlan -eq $functionAppPlan)
        {
            Write-Host "##[section]FunctionApp '$FunctionAppName' with the given plan '$appServicePlan' exists. Skipping."
        }
        else 
        {
            Write-Host "##[section]FunctionApp '$FunctionAppName' exists in plan '$functionAppPlan' and different plan '$appServicePlan' given. Updating."
            az functionapp update -n $FunctionAppName --plan $appServicePlan --force
            Confirm-Error
        }
    }

    #Check function app state (Deploy straight to production slot if it is stopped)
    $functionAppState = az functionapp show -n $FunctionAppName --query state -o tsv
    Confirm-Error
    Write-Host "Function app '$FunctionAppName' state is $functionAppState"

    #Check whether to use deployment slots
    if($functionAppState -ne "Stopped") { $deploymentSlotName = "staging" } else { $deploymentSlotName = "production" }
    if($useDeploymentSlot -ne $true) { $deploymentSlotName = "production" }
    
    Write-Host "##[section]Deploying to slot $deploymentSlotName"

    # Create deployment slot for Function app
    if($deploymentSlotName -ne "production")
    {
        Write-Host "Creating deployment slot $deploymentSlotName for function app $FunctionAppName"
        
        az functionapp deployment slot create -n $FunctionAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for function app $FunctionAppName created"  
    }

    #Stop slot app if it is running
    if($deploymentSlotName -ne "production" -and $functionAppState -ne "Stopped")
    {  
        Write-Host "##[section]Stopping deployment slot $deploymentSlotName for function app $FunctionAppName"
        
        az functionapp stop -n $functionAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for function app $FunctionAppName stopped"
    }

    #Set app settings if set
    if($AppSettings -ne $null -and $AppSettings.count -ne 0)
    {
        Write-Host "##[section]Setting app settings for function app $FunctionAppName. Count: $($AppSettings.count)"

        if($deploymentSlotName -ne "production")
        {
            az functionapp config appsettings set -n $FunctionAppName -s $deploymentSlotName --settings @AppSettings
        }
        else
        {
            az functionapp config appsettings set -n $FunctionAppName --settings @AppSettings
        }
        Confirm-Error

        Write-Host "App settings for deployment slot $deploymentSlotName for function app $FunctionAppName set"
    }

    #Set taskHubName app slot settings if set
    if($taskHubName -eq $null -or $taskHubName -eq ""){ }
    else
    {
        #Staging slot
        if($deploymentSlotName -ne "production")
        {
                Write-Host "##[section]Setting TaskHubName for deployment slot $deploymentSlotName for function app $FunctionAppName"

                $slotHubName = -join($taskHubName, $deploymentSlotName)
                $slotHubSettings = @(
                "TaskHubName=$slotHubName"
                )      
                az functionapp config appsettings set -n $FunctionAppName -s $deploymentSlotName --slot-settings @slotHubSettings
                Confirm-Error

                Write-Host "TaskHubName for deployment slot $deploymentSlotName for function app $FunctionAppName set"
        }

        #Prod slot
        Write-Host "Setting TaskHubName for deployment slot production for function app $FunctionAppName"

        $slotHubSettings = @(
        "TaskHubName=$taskHubName"
        )      
        az functionapp config appsettings set -n $FunctionAppName --slot-settings @slotHubSettings
        Confirm-Error

        Write-Host "TaskHubName for deployment slot production for function app $FunctionAppName set"
    }

    # Deploy zip
    if($deploymentSlotName -ne "production")
    {
        DeployZip $FunctionAppName $ZipPath $deploymentSlotName
    }
    else
    {
        DeployZip $FunctionAppName $ZipPath
    }
    Confirm-Error

    # Configure security
    if ($functionAppExists -eq $false -or $ForceConfigureSecurity)
    {
        Configure-FunctionAppSecurity -FunctionAppName $FunctionAppName | Out-Null
    }

    # Start slot app if it was initially running
    if($deploymentSlotName -ne "production" -and $functionAppState -ne "Stopped")
    {
        Write-Host "Starting deployment slot $deploymentSlotName for function app $FunctionAppName"

        az functionapp start -n $FunctionAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for function app $FunctionAppName started"
    }
    else
    {
        Write-Host "Skip starting deployment slot. Deployment done straight to running."
    }

    # Swap staging slot to production slot
    if($deploymentSlotName -ne "production")
    {
        SwapDeploymentSlotToProduction $FunctionAppName $deploymentSlotName
    }
    else
    {
        Write-Host "Skip Swapping deployment slot for function app $FunctionAppName, deployment done straight to production"
    }

    # Set production slot memory quota if changed
    $currentMemoryTimeQuota = az functionapp show -n $FunctionAppName --query dailyMemoryTimeQuota -o tsv
    Confirm-Error
    if($currentMemoryTimeQuota -ne $dailyMemoryTimeQuota)
    {
        Write-Host "Setting deployment slot production memory quota to $dailyMemoryTimeQuota"

        az functionapp update -n $FunctionAppName --set dailyMemoryTimeQuota=$dailyMemoryTimeQuota
        Confirm-Error

        Write-Host "Deployment slot production memory quota for function app $FunctionAppName set"
    }
    else
    {
        Write-Host "Skip setting memory quota for function app $FunctionAppName, quota up to date"
    }
}

function Publish-LogicAppStd([String] $storageAccName, [String] $KeyvaultName, [object[]] $logicAppProperties, [String[]] $appSettings, [String] $appServicePlanResourceId, [bool] $useDeploymentSlot = $false, [String] $taskHubName = "")
{
    # Set variables
    $logicAppName = $logicAppProperties.logicAppName
    $zipPath = Join-Path -Path $logicAppProperties.logicAppRoot -ChildPath $logicAppProperties.workflowLogicZipName
    $workflowParametersPath = Join-Path -Path $logicAppProperties.logicAppRoot -ChildPath $logicAppProperties.workflowParametersName
    $connectionsTemplatePath = Join-Path -Path $logicAppProperties.logicAppRoot -ChildPath $logicAppProperties.connectionsTemplateName
    $connectionsDefinitionsPath = Join-Path -Path $logicAppProperties.logicAppRoot -ChildPath "connections-output.json"

    Write-Host "Logic App Standard '$logicAppName' publish started"

    # Create Logic App Standard from scratch if it does not exist
    try 
    {
        #$logicAppStatus = az logicapp show -g $resourceGroup -n $logicAppName
        # use default resource group
        $logicAppStatus = az logicapp show -n $logicAppName
        if(($logicAppStatus -eq $null) -or ($logicAppStatus -eq ""))
        {
            $logicAppExists = $false
	    }
        else
        {
            $logicAppExists = $true
	    }
    } 
    catch 
    {
        $logicAppExists = $false
    }

    if($logicAppExists -eq $false)
    {
        # Create Logic App Standard
        Write-Host "Logic App '$logicAppName' does not exist, creating"

        az logicapp create --name $logicAppName --storage-account $storageAccName --plan $appServicePlanResourceId --disable-app-insights 'true'
        Confirm-Error

        Write-Host "Logic App '$logicAppName' created"
    }
    else
    {
        Write-Host "Logic App Standard '$logicAppName' already exists, skipping"
    }

    #Set Logic App Standard keyvault rights - identity does not transfer on slot swap
    Write-Host "Setting up Logic App Standard '$logicAppName' KeyVault rights"
    
    # NOTE: here 'functionapp' used instead of 'logicapp'
    # --> 'logicapp identity' not implemented, update when available
    (az functionapp identity assign -n $logicAppName) | Out-Null
    Confirm-Error

    $logicAppPrincipalId = az functionapp identity show -n $logicAppName --query principalId -o tsv
    Confirm-Error

    (az keyvault set-policy -n $KeyvaultName -g $securityResourceGroup --subscription $securitySubscription --object-id $logicAppPrincipalId --secret-permissions get list) | Out-Null
    Confirm-Error

    Write-Host "Logic App Standard '$logicAppName' KeyVault rights set"

    # Create default storage connection for Logic App Workflows
    Write-Host "Setting up storage connection for '$logicAppName' to '$storageAccName'"
    
    # Create storage connection
    $logicAppTenantId = (az logicapp show --name $logicAppName --query identity.tenantId -o tsv)
    Confirm-Error

    $outputs = (az deployment group create --name "APIConnections" --template-file $connectionsTemplatePath --parameters logicAppObjectId=$logicAppPrincipalId logicAppTenantId=$logicAppTenantId location=$location storageName=$storageAccName | ConvertFrom-Json).properties.outputs
    Confirm-Error

    $logicAppSubscriptionId = (az logicapp show --name $logicAppName --query id -o tsv).Split("/")[2]
    Confirm-Error

    $logicAppRgName = (az logicapp show --name $logicAppName --query resourceGroup -o tsv)
    Confirm-Error

    # Set-up variables to appsettings, needed for managedApi storage connections
    $appsettings += "WORKFLOWS_SUBSCRIPTION_ID=$logicAppSubscriptionId"
    $appsettings += "WORKFLOWS_LOCATION_NAME=$location"
    $appsettings += "WORKFLOWS_RESOURCE_GROUP_NAME=$logicAppRgName"
    $appsettings += "BLOB_CONNECTION_RUNTIMEURL=$($outputs.storageConnectionRuntimeUrl.value)"
    Confirm-Error

    # Allow Logic App to access storage
    $targetId = az storage account show --name $storageAccName --query id -o tsv
    (az role assignment create --assignee-object-id $logicAppPrincipalId --assignee-principal-type 'ServicePrincipal' --role 'Storage Blob Data Contributor' --scope $targetId) | Out-Null 
    Confirm-Error

    Write-Host "Storage connection set for '$logicAppName' to '$storageAccName'"

    #Check Logic App Standard state (Deploy straight to production slot if it is stopped)
    $logicAppState = az logicapp show -n $logicAppName --query state -o tsv
    Confirm-Error
    Write-Host "Logic App Standard '$logicAppName' state is $logicAppState"

    #Check whether to use deployment slots
    if($logicAppState -ne "Stopped") { $deploymentSlotName = "staging" } else { $deploymentSlotName = "production" }
    if($useDeploymentSlot -ne $true) { $deploymentSlotName = "production" }
    
    Write-Host "Deploying to slot $deploymentSlotName"

    # Create deployment slot for Logic App Standard
    if($deploymentSlotName -ne "production")
    {
        Write-Host "Creating deployment slot $deploymentSlotName for Logic App Standard $logicAppName"
        
        # NOTE: here 'functionapp' used instead of 'logicapp'
        # --> 'logicapp deployment' not implemented
        az functionapp deployment slot create -n $logicAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for Logic App Standard $logicAppName created"  
    }

    #Stop slot app if it is running
    if($deploymentSlotName -ne "production" -and $logicAppState -ne "Stopped")
    {  
        Write-Host "Stopping deployment slot $deploymentSlotName for Logic App Standard $logicAppName"
        
        az logicapp stop -n $logicAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for Logic App Standard $logicAppName stopped"
    }

    #Set app settings if set
    if($appSettings -eq $null -or $appSettings -eq ""){ }
    else
    {
        Write-Host "Setting app settings for deployment slot $deploymentSlotName for Logic App Standard $logicAppName"

        if($deploymentSlotName -ne "production")
        {   
            # NOTE: here 'functionapp' used instead of 'logicapp'
            # --> 'logicapp config' not implemented, update when available
            (az functionapp config appsettings set -n $logicAppName -s $deploymentSlotName --settings $appSettings) | Out-Null
        }
        else
        {
            (az functionapp config appsettings set -n $logicAppName --settings $appSettings) | Out-Null
        }
        Confirm-Error

        Write-Host "App settings for deployment slot $deploymentSlotName for Logic App Standard $logicAppName set"
    }

    #Set taskHubName app slot settings if set
    if($taskHubName -eq $null -or $taskHubName -eq ""){ }
    else
    {
        #Staging slot
        if($deploymentSlotName -ne "production")
        {
                Write-Host "Setting TaskHubName for deployment slot $deploymentSlotName for Logic App Standard $logicAppName"

                $slotHubName = -join($taskHubName, $deploymentSlotName)
                $slotHubSettings = @(
                "TaskHubName=$slotHubName"
                )

                # NOTE: here 'functionapp' used instead of 'logicapp'
                # --> 'logicapp config' not implemented, update when available
                az functionapp config appsettings set -n $logicAppName -s $deploymentSlotName --slot-settings $slotHubSettings
                Confirm-Error

                Write-Host "TaskHubName for deployment slot $deploymentSlotName for Logic App Standard $logicAppName set"
        }

        #Prod slot
        Write-Host "Setting TaskHubName for deployment slot production for Logic App Standard $logicAppName"

        $slotHubSettings = @(
        "TaskHubName=$taskHubName"
        )
        
        # NOTE: here 'functionapp' used instead of 'logicapp'
        # --> 'logicapp config' not implemented, update when available
        az functionapp config appsettings set -n $logicAppName --slot-settings $slotHubSettings
        Confirm-Error

        Write-Host "TaskHubName for deployment slot production for Logic App Standard $logicAppName set"
    }

    #Deploy Logic app component
    # NOTE: here 'functionapp' used instead of 'logicapp'
    # --> 'logicapp deploy' not implemented, update when available
    if($deploymentSlotName -ne "production")
    {   
        # workflows
        DeployZip $logicAppName $zipPath $deploymentSlotName

        # parameters
        Write-Host "Deploy parameters to $deploymentSlotName"
        az functionapp deploy --resource-group $logicAppRgName --name $logicAppName --src-path $workflowParametersPath --slot $deploymentSlotName --type static --target-path parameters.json

        # connections
        Write-Host "Deploy connections to $deploymentSlotName"
        az functionapp deploy --resource-group $logicAppRgName --name $logicAppName --src-path $connectionsDefinitionsPath --slot $deploymentSlotName --type static --target-path connections.json
    }
    else
    {
        # workflows
        DeployZip $logicAppName $zipPath

        # parameters
        Write-Host "Deploy parameters to $deploymentSlotName"
        az functionapp deploy --resource-group $logicAppRgName --name $logicAppName --src-path $workflowParametersPath --type static --target-path parameters.json

        # connections
        Write-Host "Deploy connections to $deploymentSlotName"
        az functionapp deploy --resource-group $logicAppRgName --name $logicAppName --src-path $connectionsDefinitionsPath --type static --target-path connections.json
    }
    Confirm-Error

    #Start slot app if it was initially running
    if($deploymentSlotName -ne "production" -and $logicAppState -ne "Stopped")
    {
        Write-Host "Starting deployment slot $deploymentSlotName for Logic App Standard $logicAppName"

        az logicapp start -n $logicAppName -s $deploymentSlotName
        Confirm-Error

        Write-Host "Deployment slot $deploymentSlotName for Logic App Standard $logicAppName started"
    }

    #Swap staging slot to production slot
    if($deploymentSlotName -ne "production")
    {
        SwapDeploymentSlotToProduction $logicAppName $deploymentSlotName
    }
    else
    {
        Write-Host "Skip Swapping deployment slot for Logic App Standard $logicAppName, deployment done straight to production"
	}


    #Set production slot memory quota if changed  
    $currentMemoryTimeQuota = az logicapp show -n $logicAppName --query dailyMemoryTimeQuota -o tsv
    Confirm-Error
    if($currentMemoryTimeQuota -ne $dailyMemoryTimeQuota)
    {
        Write-Host "Setting deployment slot production memory quota for Logic App Standard $logicAppName"
        
        # NOTE: here 'functionapp' used instead of 'logicapp'
        # --> 'logicapp update' not implemented, update when available
        (az functionapp update -n $logicAppName --set dailyMemoryTimeQuota=$dailyMemoryTimeQuota) | Out-Null
        Confirm-Error

        Write-Host "Deployment slot production memory quota for Logic App Standard $logicAppName set"
	}
    else
    {
        Write-Host "Skip setting memory quota for Logic App Standard $logicAppName, quota up to date"
    }
}

function Publish-AppServicePlan([String] $appServicePlanName, [String] $sku = "Y1", [int] $minInstances = 1, [int] $maxBurst = 10) {
    # App service plans
    # Y1 Dynamic
    # F1(Free)
    # D1(Shared)
    # B1(Basic Small)
    # B2(Basic Medium)
    # B3(Basic Large)
    # S1(Standard Small)
    # P1V2(Premium V2 Small)
    # P1V3(Premium V3 Small)
    # P2V3(Premium V3 Medium)
    # P3V3(Premium V3 Large)
    # PC2 (Premium Container Small)
    # PC3 (Premium Container Medium)
    # PC4 (Premium Container Large)
    # I1 (Isolated Small)
    # I2 (Isolated Medium)
    # I3 (Isolated Large)
    # I1v2 (Isolated V2 Small)
    # I2v2 (Isolated V2 Medium)
    # I3v2 (Isolated V2 Large)
    # WS1 (Logic Apps Workflow Standard 1)
    # WS2 (Logic Apps Workflow Standard 2)
    # WS3 (Logic Apps Workflow Standard 3)

    #Function app Premium plans
    #EP1
    #EP2
    #EP3

    #Function app consumption plans:
    #Y1

    Write-Host "AppServicePlan '$appServicePlanName' publish started"
    
    # Create AppServicePlan from scratch if it does not exist
    try 
    {
        $appServiceStatus = az appservice plan show --name $appServicePlanName
        if(($appServiceStatus -eq $null) -or ($appServiceStatus -eq ""))
        {
            $appServiceExists = $false
	    }
        else
        {
            $appServiceExists = $true
	    }
    } 
    catch 
    {
        $appServiceExists = $false
    }

    if($appServiceExists -eq $false)
    {
        # Create AppServicePlan
        Write-Host "AppServicePlan '$appServicePlanName' does not exist, creating"
   
        if (($sku -eq "EP1") -or ($sku -eq "EP2") -or ($sku -eq "EP3")) {
            az functionapp plan create -n $appServicePlanName --min-instances $minInstances --max-burst $maxBurst --sku $sku
        }
        elseif ($sku -eq "Y1") {
            # Create a specifically-named consumption (Y1) app service plan, json parameter must be double-escaped to run in powershell
            az resource create --name $appServicePlanName --resource-type Microsoft.web/serverfarms --is-full-object --properties "{\`"location\`":\`"westeurope\`",\`"sku\`":{\`"name\`":\`"Y1\`",\`"tier\`":\`"Dynamic\`"}}"
        } else {
            az appservice plan create -n $appServicePlanName --sku $sku
        }

        Confirm-Error

        Write-Host "AppServicePlan '$appServicePlanName' created"
    }
    else
    {
        # Update AppServicePlan
        Write-Host "AppServicePlan '$appServicePlanName' exists. Updating."

        if (($sku -eq "EP1") -or ($sku -eq "EP2") -or ($sku -eq "EP3"))
        {
            az functionapp plan update -n $appServicePlanName --sku $sku --min-instances $minInstances --max-burst $maxBurst
        }
        elseif ($sku -eq 'Y1' -and $appServiceStatus.sku.name -eq $sku)
        {
            Write-Host "AppServicePlan '$appServicePlanName' tier is Y1 (Dynamic), skipping update"
        }
        else
        {
            az appservice plan update -n $appServicePlanName --sku $sku
        }
        Confirm-Error

        Write-Host "AppServicePlan '$appServicePlanName' updated"
    }
}

function Publish-FileShare([String[]] $subFolders, [String] $accountName, [String] $shareName, [String] $resourceGroup, [String] $KeyvaultName)
{
    Publish-StorageAccount $accountName $KeyvaultName

    Write-Host "Resolving Storage account key for share creation"
    $storageAccountKey = $(az storage account keys list --resource-group $resourceGroup --account-name $accountName --query "[0].value" | tr -d '"')
    Confirm-Error

    Write-Host "Creating share $shareName"
    az storage share create --name $shareName --account-name $accountName --account-key $storageAccountKey
    Confirm-Error

    if($subFolders -ne $null)
    {
        Write-Host "Sub folders given as parameter, creating folders to share"
        $subFolders| % {az storage directory create --account-name $accountName --account-key $storageAccountKey --share-name $shareName --name "$_" --output none}
    }
    Confirm-Error
}

function Upload-FileToFileShare
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $AccountName,
        [Parameter(Mandatory=$true)]
        [string] $ShareName,
        [Parameter(Mandatory=$true)]
        [string] $SourcePath,
        [Parameter(Mandatory=$true)]
        [string] $DestinationFilename,
        [Parameter(Mandatory=$true)]
        [string] $DestinationFolder
    )

    Write-Host "Resolving Storage account '$AccountName' key for file upload."
    $accountKey = $(az storage account keys list --account-name $AccountName --query "[0].value" | tr -d '"')

    Write-Host "Creating destination folder '$DestinationFolder'."
    az storage directory create `
        --account-key "$accountKey" `
        --account-name "$AccountName" `
        --share-name "$ShareName" `
        --name "$DestinationFolder" `
        --output none
    Confirm-Error
    
    Write-Host "Uploading '$SourcePath' to '$DestinationFilename'."
    az storage file upload `
        --account-key "$accountKey" `
        --account-name "$AccountName" `
        --share-name "$ShareName" `
        --path "$DestinationFolder/$DestinationFilename" `
        --source "$SourcePath"
    Confirm-Error
}

function Write-FunctionConnections([object[]] $inputFunctions, [string] $logicAppRoot) {

    $sourcePath = Join-Path -Path $logicAppRoot -ChildPath 'connections.json'
    $ConnectionsObject = Get-Content -Path $sourcePath | ConvertFrom-Json
    Confirm-Error

    Foreach ($item in $inputFunctions) {

        # Use supplied or default subscription name or id, convert name to number string
        if(($null -eq $item.functionAppSubscription) -or ($item.functionAppSubscription -eq "")) {

            $functionSubscriptionId = az account show --query id -o tsv

	    } else {

            $functionSubscriptionId = az account show --subscription "$($item.functionAppSubscription)" --query id -o tsv
        }
        Confirm-Error
        
        $connName = "funcConn$($item.functionName)"

        $connectionBlockContent = @{
            authentication = @{
                name  = "Code"
                type  = "QueryString"
                value = "@appsetting('$($item.functionName)_key')"
            }
            displayName    = $connName
            function       = @{
                id = "/subscriptions/$($functionSubscriptionId)/resourceGroups/$($item.functionAppRG)/providers/Microsoft.Web/sites/$($item.functionAppName)/functions/$($item.functionName)"
            }
            triggerUrl     = "https://$($item.functionAppName).azurewebsites.net/api/$($item.functionName)"
        }
        Confirm-Error
        
        # Append definition to connections
        $ConnectionsObject.functionConnections | Add-Member -Name $connName -value $connectionBlockContent -MemberType NoteProperty
        Confirm-Error
    }

    # Write connections definitions to disk
    $outputPath = Join-Path -Path $logicAppRoot -ChildPath 'connections-output.json'
    ConvertTo-Json($ConnectionsObject) -Depth 4 | Set-Content -Path $outputPath
    Confirm-Error
}

function Publish-PublicIp([string] $rgName, [string] $ipName, [string] $dnsPrefix, [int] $idleTimeout = 4, [string] $allocationMethod = "Static", [string] $sku = "Standard") {
    # Available values
    # allocationMethod: "Static"/"Dynamic"
    # sku: "Standard" / "Basic"
    
    Write-Host "Public IP '$ipName' publish started"

    # Create Public IP from scratch if it does not exist
    try 
    {
        $ipStatus = az network public-ip show -n $ipName -g $rgName
        if(($ipStatus -eq $null) -or ($ipStatus -eq ""))
        {
            $ipExists = $false
	    }
        else
        {
            $ipExists = $true
	    }
    } 
    catch 
    {
        $ipExists = $false
    }

    if($ipExists -eq $false)
    {
        # Create Public IP
        Write-Host "Public IP '$ipName' does not exist, creating"

        if(-not ([String]::IsNullOrEmpty($dnsPrefix))) {
            az network public-ip create -n $ipName --dns-name $dnsPrefix --idle-timeout $idleTimeout --allocation-method $allocationMethod --sku $sku -g $rgName
        }
        else {
            az network public-ip create -n $ipName --idle-timeout $idleTimeout --allocation-method $allocationMethod --sku $sku -g $rgName
        }
        Confirm-Error

        Write-Host "Public IP '$ipName' created"
    }
    else
    {
        # Update Public IP
        Write-Host "Public IP '$ipName' already exists, updating"

        if(-not ([String]::IsNullOrEmpty($dnsPrefix))) {
            az network public-ip update -n $ipName --dns-name $dnsPrefix --idle-timeout $idleTimeout --allocation-method $allocationMethod --sku $sku -g $rgName
        }
        else {
            az network public-ip update -n $ipName --idle-timeout $idleTimeout --allocation-method $allocationMethod --sku $sku -g $rgName
        }
        Confirm-Error

        Write-Host "Public IP '$ipName' updated"
    }
}

function Publish-NatGateway([string] $rgName, [string] $ngwName, [string[]] $publicIps, [int] $idleTimeout = 4) {
    Write-Host "NAT Gateway '$ngwName' publish started"
    
    Write-Host "NAT Gateway '$ngwName' Public IP list '$publicIps'"

    # Create NAT Gateway from scratch if it does not exist
    try 
    {
        $ngwStatus = az network nat gateway show -n $ngwName -g $rgName
        if(($ngwStatus -eq $null) -or ($ngwStatus -eq ""))
        {
            $ngwExists = $false
	    }
        else
        {
            $ngwExists = $true
	    }
    } 
    catch 
    {
        $ngwExists = $false
    }

    if($ngwExists -eq $false)
    {
        # Create NAT Gateway
        Write-Host "NAT Gateway '$ngwName' does not exist, creating"

        az network nat gateway create -n $ngwName --public-ip-addresses @publicIps --idle-timeout $idleTimeout -g $rgName
        Confirm-Error

        Write-Host "NAT Gateway '$ngwName' created"
    }
    else
    {
        # Update NAT Gateway
        Write-Host "NAT Gateway '$ngwName' already exists, updating"

        az network nat gateway update -n $ngwName --public-ip-addresses @publicIps --idle-timeout $idleTimeout -g $rgName
        Confirm-Error

        Write-Host "NAT Gateway '$ngwName' updated"
    }
}

function Publish-Vnet([string] $rgName, [string] $vnetName, [string[]] $ipAddressPrefixes = @("10.0.0.0/16")) {
    Write-Host "VNET '$vnetName' publish started"
    
    Write-Host "VNET '$vnetName' IP address prefix list '$ipAddressPrefixes'"

    # Create VNET from scratch if it does not exist
    try 
    {
        $vnetStatus = az network vnet show -n $vnetName -g $rgName
        if(($vnetStatus -eq $null) -or ($vnetStatus -eq ""))
        {
            $vnetExists = $false
	    }
        else
        {
            $vnetExists = $true
	    }
    } 
    catch 
    {
        $vnetExists = $false
    }

    if($vnetExists -eq $false)
    {
        # Create VNET
        Write-Host "VNET '$vnetName' does not exist, creating"

        az network vnet create -n $vnetName --address-prefixes @ipAddressPrefixes -g $rgName
        Confirm-Error

        Write-Host "VNET '$vnetName' created"
    }
    else
    {
        # Update VNET
        Write-Host "VNET '$vnetName' already exists, updating"

        az network vnet update -n $vnetName --address-prefixes @ipAddressPrefixes -g $rgName
        Confirm-Error

        Write-Host "VNET '$vnetName' updated"
    }
}

function Publish-Subnet([string] $rgName, [string] $vnetName, [string] $subnetName, [string[]] $ipAddressPrefixes = @("10.0.0.0/24"), [string] $ngwName = $null)
{
    Write-Host "VNET '$vnetName' subnet '$subnetName' publish started"
    Write-Host "VNET '$vnetName' subnet '$subnetName' IP address prefix list '$ipAddressPrefixes'"
    Write-Host "VNET '$vnetName' subnet '$subnetName' NAT Gateway name '$ngwName'"

    # Create Subnet from scratch if it does not exist
    try 
    {
        $subnetStatus = az network vnet subnet show -n $subnetName --vnet-name $vnetName -g $rgName
        if(($subnetStatus -eq $null) -or ($subnetStatus -eq ""))
        {
            $subnetExists = $false
	    }
        else
        {
            $subnetExists = $true
	    }
    } 
    catch 
    {
        $subnetExists = $false
    }

    if($subnetExists -eq $false)
    {
        # Create Subnet 
        Write-Host "Subnet '$subnetName' does not exist, creating"

        if(-not ([String]::IsNullOrEmpty($ngwName))){
             az network vnet subnet create -n $subnetName --vnet-name $vnetName --address-prefixes @ipAddressPrefixes --nat-gateway $ngwName -g $rgName
        }
        else {
            az network vnet subnet create -n $subnetName --vnet-name $vnetName --address-prefixes @ipAddressPrefixes -g $rgName
        }   
        Confirm-Error

        Write-Host "Subnet '$subnetName' created"
    }
    else
    {
        # Update Subnet
        Write-Host "Subnet '$subnetName' already exists, updating"

        if(-not ([String]::IsNullOrEmpty($ngwName))){
            az network vnet subnet update -n $subnetName --vnet-name $vnetName --address-prefixes @ipAddressPrefixes --nat-gateway $ngwName -g $rgName
        }
        else {
            az network vnet subnet update -n $subnetName --vnet-name $vnetName --address-prefixes @ipAddressPrefixes -g $rgName
        }   
        Confirm-Error

        Write-Host "Subnet '$subnetName' updated"
    }
}

function Configure-StorageVnet([string] $AccountName, [string] $VnetName = $sharedVnetName, [string] $SubnetName = $sharedSubnetName, [string] $RgName = $sharedResourceGroup)
{
    Write-Host "Connect storage '$AccountName' to VNET '$VnetName' subnet '$SubnetName'"

    # Find shared subnet.
    $subnetId = az network vnet subnet show -g $RgName -n $SubnetName --vnet-name $VnetName --query id --output tsv
    Confirm-Error

    # Join the storage account to the subnet.
    az storage account network-rule add --account-name $AccountName --subnet $subnetId
    Confirm-Error

    Write-Host "Storage VNET configured."
}

function Configure-SecureStorage([string] $AccountName)
{
    Write-Host "Configuring secure storage."

    # White-list a service IP.
    if ($serviceIP)
    {
        az storage account network-rule add --account-name $AccountName --ip-address $serviceIP
        Confirm-Error
    }
    # White-list additional IPs.
    foreach ($ipAddr in $additionalServiceIPs)
    {
        az storage account network-rule add --account-name $AccountName --ip-address $ipAddr
        Confirm-Error
    }

    # Deny access to the storage account from the outside.
    az storage account update -n $AccountName --bypass AzureServices --default-action Deny
    Confirm-Error

    Write-Host "Secure storage configured."
}

function Configure-FunctionAppSecurity([string] $FunctionAppName)
{
    Write-Host "##[section]FunctionApp - Configure security."

    # Disable basic authentication.
    Write-Host "##[section]FunctionApp - Disable basic authentication for FTP publish."
    az resource update --name ftp --namespace Microsoft.Web --resource-type basicPublishingCredentialsPolicies --parent sites/$FunctionAppName --set properties.allow=false
    Confirm-Error
    Write-Host "##[section]FunctionApp - Disable basic authentication for SCM publish."
    az resource update --name scm --namespace Microsoft.Web --resource-type basicPublishingCredentialsPolicies --parent sites/$FunctionAppName --set properties.allow=false
    Confirm-Error

    # Disable deploy via FTP since we don't use it.
    Write-Host "##[section]FunctionApp - Disable FTP."
    az functionapp config set -n $FunctionAppName --min-tls-version 1.2 --ftps-state FtpsOnly
    Confirm-Error
}

function Configure-FunctionAppVnet([string] $FunctionAppName, [string] $VnetName, [string] $SubnetName, [string] $RgName = $null, $ForceOutboundTrafficToVnet = $null)
{
    Write-Host "Integrating FunctionApp '$FunctionAppName' to VNET '$VnetName' subnet '$SubnetName'"

    if ($RgName)
    {
        az functionapp vnet-integration add -n $FunctionAppName --vnet "/subscriptions/$sharedSubscriptionId/resourceGroups/$RgName/providers/Microsoft.Network/virtualNetworks/$VnetName" --subnet $SubnetName
    }
    else
    {
        az functionapp vnet-integration add -n $FunctionAppName --vnet $VnetName --subnet $SubnetName
    }
    Confirm-Error

    if ($ForceOutboundTrafficToVnet -eq $true)
    {
        Write-Host "Forcing FunctionApp '$FunctionAppName' all traffic routing to VNET '$VnetName' subnet '$SubnetName'"

        az functionapp config set -n $FunctionAppName --vnet-route-all-enabled $ForceOutboundTrafficToVnet
    }
    elseif ($ForceOutboundTrafficToVnet -eq $false)
    {
        Write-Host "Disabling FunctionApp '$FunctionAppName' forcing of outbound traffic to use VNET '$VnetName' subnet '$subnetName'"

        az functionapp config set -n $FunctionAppName --vnet-route-all-enabled $ForceOutboundTrafficToVnet
    }
    Confirm-Error

    Write-Host "FunctionApp '$FunctionAppName' to VNET '$VnetName' subnet '$subnetName' integration configured"
}

function Configure-FunctionAppScaleLimit([string] $functionAppName, [int] $scaleLimit) {
    
    Write-Host "Setting FunctionApp '$functionAppName' scale limit to '$scaleLimit'"
    
    az resource update --resource-type Microsoft.Web/sites -n $functionAppName/config/web --set properties.functionAppScaleLimit=$scaleLimit
    Confirm-Error

    Write-Host "FunctionApp '$functionAppName' scale limit set to '$scaleLimit'"
}

function Configure-FunctionPlanInstanceLimits([string] $functionPlanName, [int] $minInstances, [int] $maxBurstLimit) {
    
    Write-Host "Setting Premium Function App plan '$functionPlanName' min instances to '$minInstances' and max burst limit to '$maxBurstLimit'"
    
    az functionapp plan update -n $functionPlanName --min-instances $minInstances --max-burst $maxBurstLimit
    Confirm-Error

    Write-Host "Premium Function App plan '$functionPlanName' min instances set to '$minInstances' and max burst limit set to '$maxBurstLimit'"
}

function Configure-FunctionPlanSku([string] $functionPlanName, [string] $sku) {
    
    Write-Host "Setting Premium Function App plan '$functionPlanName' sku to '$sku'"
    
    az functionapp plan update -n $functionPlanName --sku $sku
    Confirm-Error

    Write-Host "Premium Function App plan '$functionPlanName' sku set to '$sku'"
}

function Configure-KeyVaultSecretPermissions
{
    Param
    (
        [Parameter(Mandatory=$true)] [string]   $KeyvaultName,
        [Parameter(Mandatory=$true)] [string[]] $ObjectIds,
        [Parameter(Mandatory=$false)][string]   $ResourceGroup,
        [Parameter(Mandatory=$false)][string[]] $Permissions = @('get', 'list')
    )
    Write-Host "Configuring $KeyvaultName secret permissions started."
    
    #Set secret permissions to KeyVault
    ForEach ($objectId in $ObjectIds)
    {
        Write-Host "Setting KeyVault secret permissions '$Permissions' for $objectId"
        if ($ResourceGroup)
        {
            az keyvault set-policy --name $KeyvaultName --resource-group $ResourceGroup --object-id $objectId --secret-permissions @Permissions
        }
        else
        {
            az keyvault set-policy --name $KeyvaultName --object-id $objectId --secret-permissions @Permissions
        }
        Confirm-Error
    }
    Write-Host 'KeyVault secret permissions set.'
}

function Publish-ApplicationInsights-ApiKey([String] $appInsightsName, [String] $resourceGroup, [String] $apiKeyName, [String] $KeyvaultName, [String] $apiKeyKeyvaultSecretName = $null) {
    Write-Host "AppInsights $appInsightsName ApiKey $apiKeyName publish started"

    try 
    {
        az extension add --name application-insights

        $apiKeyStatus = az monitor app-insights api-key show -g $resourceGroup -a $appInsightsName --api-key $apiKeyName
        if(($apiKeyStatus -eq $null) -or ($apiKeyStatus -eq ""))
        {
            $apiKeyExists = $false
	    }
        else
        {
            $apiKeyExists = $true
	    }
    }
    catch
    {
        $apiKeyExists = $false
    }

    if ($apiKeyExists -eq $false)
    {
        Write-Host "AppInsights $appInsightsName API key $apiKeyName does not exist, creating"

        $apiKey = (az monitor app-insights api-key create -g $resourceGroup -a $appInsightsName --api-key $apiKeyName --read-properties "ReadTelemetry" --write-properties '""' | ConvertFrom-Json).apiKey
        Confirm-Error

        Write-Host "AppInsights $appInsightsName API key $apiKeyName created"

        #API key is apparently returned only on initial create command response, so no updating
        if (-not ([String]::IsNullOrEmpty($apiKeyKeyvaultSecretName)))
        {
            Write-Host "Setting up AppInsights API key '$apiKeyName' secret '$apiKeyKeyvaultSecretName' to KeyVault"  

            Update-KeyvaultSecretValue-IfDifferent `
                -KeyvaultName $KeyvaultName `
                -KeyvaultSecretName $apiKeyKeyvaultSecretName `
                -Value $apiKey
            Confirm-Error

            Write-Host "AppInsights API key '$apiKeyName' secret '$apiKeyKeyvaultSecretName' to KeyVault set"
        }
    }
    else
    {
        Write-Host "AppInsights $appInsightsName API key $apiKeyName already exists, skipping"
    }
}

function Get-ADGroupObjectId([string] $adGroupName)
{
    Write-Host "Getting AD group '$adGroupName' objectId"

    $adGroup = az ad group show -g $adGroupName | ConvertFrom-Json
    Confirm-Error

    return $adGroup.objectId
}

function Publish-ServiceBusNamespace
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $Name,
        [Parameter(Mandatory=$false)]
        [string] $ResourceGroup,
        [Parameter(Mandatory=$false)]
        [string] $KeyvaultName,
        [Parameter(Mandatory=$false)]
        [string[]] $KeyvaultSecretName = "SBConnectionString"
    )

    Write-Host "##[group]ServiceBus Namespace '$Name' in resource group '$ResourceGroup' publishing started"
    
    $params = @()
    # if $ResourceGroup is not specified, current will be used in this context
    if (-not ([String]::IsNullOrEmpty($ResourceGroup)))
    {
        $params += "--resource-group", $ResourceGroup
    }

    $servicebuses = az servicebus namespace list $params `
        | ConvertFrom-Json `
        | Where-Object {$_.name -eq $Name}
    if ($servicebuses.count -eq 0)
    {
        Write-Host "ServiceBus Namespace $Name does not exist, creating"
        az servicebus namespace create $params `
            --name $Name `
            | Out-Null
        Confirm-Error
        Write-Host "Created"
    }

    if (-not ([String]::IsNullOrEmpty($KeyvaultName)))
    {
        $params += "--namespace-name", $Name

        Write-Host "Storing storage connection string into keyvault secret '$KeyvaultSecretName'"
        $RootManageSharedAccessKey = az servicebus namespace authorization-rule keys list $params `
            --name RootManageSharedAccessKey `
            | ConvertFrom-Json
        Update-KeyvaultSecretValue-IfDifferent `
            -KeyvaultName $KeyvaultName `
            -KeyvaultSecretName $KeyvaultSecretName `
            -Value $RootManageSharedAccessKey.primaryConnectionString
        Confirm-Error
    }

    Write-Host "##[endgroup]"
}

function Update-KeyvaultSecretValue-IfDifferent
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $KeyvaultName,
        [Parameter(Mandatory=$true)]
        [string[]] $KeyvaultSecretName,
        [Parameter(Mandatory=$true)]
        [string] $Value
    )

    Write-Host "Creating/updating KeyVault '$KeyvaultName' secret '$KeyvaultSecretName' value"

    $createValue = $true
    $existingSecret = az keyvault secret list `
        --vault-name $KeyvaultName `
        | ConvertFrom-Json `
        | Where-Object {$_.name -eq $KeyvaultSecretName}
    $secretExists = ($existingSecret.count -eq 1)

    if ($secretExists)
    {
        Write-Host "Secret exists"
        $existingSecret = az keyvault secret show `
            --name $KeyvaultSecretName `
            --vault-name $KeyvaultName `
            | ConvertFrom-Json
        if (($existingSecret.value -eq $Value) -and ($existingSecret.attributes.enabled -eq $true))
        {
            Write-Host "Secret value is enabled and new value is the same as old, update skipped"
            $createValue = $false
        }
    }
    if ($createValue)
    {
        # disable old value    
        if ($secretExists -and ($existingSecret.attributes.enabled -eq $true))
        {
            Write-Host "Disabling old value"
            az keyvault secret set-attributes `
                --vault-name $KeyvaultName `
                --name $KeyvaultSecretName `
                --enabled false
            Confirm-Error
        }

        Write-Host "Creating new value"
        az keyvault secret set `
            --vault-name $KeyvaultName `
            --name $KeyvaultSecretName `
            --value $Value
        Confirm-Error
    }

    Write-Host "Created/updated"
}

function Create-KeyvaultSecrets-IfNotExist
{
    Param
    (
        [Parameter(Mandatory=$true)][string] $KeyvaultName,
        [Parameter(Mandatory=$true)][hashtable] $Secrets
    )
    Write-Host "Checking KeyVault '$KeyvaultName' secrets."

    $existingSecrets = az keyvault secret list --vault-name $KeyvaultName `
        | ConvertFrom-Json
    Confirm-Error

    foreach($kv in $Secrets.GetEnumerator())
    {
        $name = $kv.key
        $secretValue = $kv.value
        $notExists = ($existingSecrets | Where-Object {$_.name -eq $name}).count -eq 0
        if ($notExists)
        {
            Write-Host "Creating '$name'"
            az keyvault secret set --vault-name $KeyvaultName `
                --name $name `
                --value $secretValue
            Confirm-Error
            Write-Host "Created."
        }
        else
        {
            Write-Host "Secret '$name' exists."
        }
    }
}

function Publish-BicepTemplate {
    param(
        [string]$DeploymentName,
        [string]$ResourceGroup,
        [string]$TemplateFilePath,
        [hashtable]$Parameters
    )

    # Convert parameters to proper format
    $parameterArguments = @()
    foreach ($key in $Parameters.Keys) {
        if ($Parameters[$key] -is [hashtable]) {
            # Convert hashtable to JSON string
            $jsonValue = $Parameters[$key] | ConvertTo-Json -Compress
            $parameterArguments += "--parameters", "$key=$jsonValue"
        } else {
            $parameterArguments += "--parameters", "$key=$($Parameters[$key])"
        }
    }

    # Execute deployment
    az deployment group create `
        --name $DeploymentName `
        --resource-group $ResourceGroup `
        --template-file $TemplateFilePath `
        $parameterArguments

    Confirm-Error
}

function Test-BicepDeployment {
    param(
        [string]$DeploymentName,
        [string]$ResourceGroup,
        [string]$TemplateFilePath,
        [hashtable]$Parameters
    )

    Write-Host "Testing Bicep deployment '$DeploymentName' in resource group '$ResourceGroup'"

    try {
        # Convert parameters to proper format
        $parameterArguments = @()
        foreach ($key in $Parameters.Keys) {
            if ($Parameters[$key] -is [hashtable]) {
                # Convert hashtable to JSON string
                $jsonValue = $Parameters[$key] | ConvertTo-Json -Compress
                $parameterArguments += "--parameters", "$key=$jsonValue"
            } else {
                $parameterArguments += "--parameters", "$key=$($Parameters[$key])"
            }
        }

        # Execute what-if deployment
        $result = az deployment group what-if `
            --name $DeploymentName `
            --resource-group $ResourceGroup `
            --template-file $TemplateFilePath `
            $parameterArguments

        Write-Host "Deployment test completed successfully"
        Write-Host "Changes preview:"
        Write-Host ($result | Out-String)  # Ensure it's printed

        return $true
    }
    catch {
        Write-Error "Deployment test failed: $_"
        return $false
    }
}

#Keep this last, used to determine if loading script successful
exit 0
