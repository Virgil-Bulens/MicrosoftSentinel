#
# Variables
#
$ErrorActionPreference = "Stop"
$OrganizationId = "<id>"
$BaseUri = "https://reports.api.umbrella.com/v1/organizations/$OrganizationId/security-activity"
$KeyVaultName = "<Name of the Key Vault where you stored the Umbrella API Key and Secret>"
$ApiKeyName = "umbrellaApiKey"
$ApiSecretName = "umbrellaApiSecret"


#
# Authentication
#
# Az
Connect-AzAccount -Identity | `
    Out-Null


#
# Main
#
# Get Umbrella API keys and create credential
$ApiKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName `
    -Name $ApiKeyName `
    -AsPlainText

$ApiSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName `
    -Name $ApiSecretName `
    -AsPlainText | `
    ConvertTo-SecureString -AsPlainText `
    -Force

$Credential = New-Object -TypeName Management.Automation.PSCredential `
    -ArgumentList $ApiKey, $ApiSecret

# Get Unix Timestamp
$UnixTimeNow = [long] (Get-Date -Date ((Get-Date).ToUniversalTime()) -UFormat %s)
$UnixTimeOneHourAgo = $UnixTimeNow - 3600

# Construct URI
$Uri = $BaseUri + "?limit=500&start=" + $UnixTimeOneHourAgo

# Get past hour's logs in JSON format
$Requests = Invoke-RestMethod -Method Get `
    -Uri $Uri `
    -Credential $Credential | `
    Foreach-Object Requests | `
    ConvertTo-Json

# Feed the log files to Sentinel's Log Analytics Workspace
. ./Send-LogAnalyticsData.ps1 -LogType Cisco_Umbrella_dns `
    -Json $Requests `
    -TimeStampField datetime