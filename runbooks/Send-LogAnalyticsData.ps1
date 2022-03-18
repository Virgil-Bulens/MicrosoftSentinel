#
# Parameters
#
Param (
    # Type of Log
    [Parameter(
        Mandatory = $true,
        Position = 0
    )]
    [string]
    $LogType,

    # The log in JSON format
    [Parameter(
        Mandatory = $true,
        Position = 1
    )]
    [string]
    $Json,

    # Field in the log that contains the timestamp
    [Parameter(
        Mandatory = $false,
        Position = 2
    )]
    [string]
    $TimeStampField
)


#
# Variables
#
$ErrorActionPreference = "Stop"
$CustomerId = "<Your Log Analytics Workspace ID>"
$KeyVaultName = "<Name of the Key Vault where you stored the Workspace key>"
$SecretName = "sentinelWorkspaceKey"
$Method = "POST"
$ContentType = "application/json"
$Resource = "/api/logs"
$Uri = "https://" + $CustomerId + ".ods.opinsights.azure.com" + $Resource + "?api-version=2016-04-01"



#
# Authentication
#
if ( -not ( Get-AzContext -ErrorAction SilentlyContinue ) )
{
    Connect-AzAccount -Identity | `
        Out-Null
}


#
# Main
#
# Get the Workspace key
$SharedKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName `
    -Name $SecretName `
    -AsPlainText

# Calculate the hash for authentication to Log Analytics Workspace
$Date = [DateTime]::UtcNow.ToString("r")
$XHeaders = "x-ms-date:" + $Date

$Body = ([System.Text.Encoding]::UTF8.GetBytes($Json))
$ContentLength = $Body.Length

$StringToHash = $Method + "`n" + $ContentLength + "`n" + $ContentType + "`n" + $XHeaders + "`n" + $Resource
$BytesToHash = [Text.Encoding]::UTF8.GetBytes($StringToHash)

$KeyBytes = [Convert]::FromBase64String($SharedKey)

$Sha256 = New-Object System.Security.Cryptography.HMACSHA256
$Sha256.Key = $KeyBytes

$CalculatedHash = $Sha256.ComputeHash($BytesToHash)

$EncodedHash = [Convert]::ToBase64String($CalculatedHash)
$Authorization = "SharedKey " + $CustomerId + ":" + $EncodedHash

# Send the log(s) to Log Analytics Workspace
$Headers = @{
    "Authorization"        = $Authorization
    "Log-Type"             = $LogType
    "x-ms-date"            = $Date
    "time-generated-field" = $TimeStampField
}

Invoke-RestMethod -Uri $Uri `
    -Method $Method `
    -ContentType $ContentType `
    -Headers $Headers `
    -Body $Body `
    -UseBasicParsing
