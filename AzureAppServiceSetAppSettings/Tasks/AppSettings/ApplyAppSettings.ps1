[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,

    [String] [Parameter(Mandatory = $true)]
    $WebAppName,
    
    [String] [Parameter(Mandatory = $true)]
    $ResourceGroupName,

    [String] [Parameter(Mandatory = $true)]
    $AppSettings
)

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

Write-Host("=== START ===")
Write-Host ("Webapp: " + $WebAppName)
Write-Host ("Appsettings: " + $AppSettings)

$seperator = [Environment]::NewLine
$splitOption = [System.StringSplitOptions]::RemoveEmptyEntries

$lines = $AppSettings.Split($seperator, $splitOption)
Write-Host ("Lines found: " + $lines.Count)

$webApp = Get-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName
$appSettingList = $WebApp.SiteConfig.AppSettings

$hash = @{}

foreach ($kvp in $appSettingList) {
    $hash[$kvp.Name] = $kvp.Value.ToString()
    Write-Host ("Found - Key: " + $kvp.Name + " Value: " + $kvp.Value)
}

foreach ($keyValue in $lines) {
    $key,$val = $keyValue.Split("'", $splitOption)
    $hash[$key.ToString().Replace("=","").Trim()] = $val
    Write-Host ("Adding - Key: " + $key.Replace("=","")  + " Value: " + $val)
}

Set-AzureRMWebApp -Name $WebAppName -ResourceGroupName $ResourceGroupName -AppSettings $hash
Write-Host("=== DONE ===")
