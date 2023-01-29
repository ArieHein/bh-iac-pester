# Get input from pipeline step
param (
    [Parameter(Mandatory)][string]$Cloud="Azure"
)

# Install the Pester module from PowerShell Gallery
Install-Module -Name Pester -Scope CurrentUser -Force

# Read the project config file
$jsonPath = ".\" + $Cloud.ToLower() + '\config.json'
$config = Get-Content -Path $jsonPath | ConvertFrom-Json

# Adjust for differernt Cloud vendors
$SubscriptionName = $config.SubscriptionName
$ResourceName = $config.$ResourceName
$ResourceLocation = $config.$ResourceLocation
$EnvironmentName = $config.EnvironmentName
$ProjectName = $config.ProjectName

$ResourceTags = @{
    EnvironmentName = $EnvironmentName
    ProjectName = $ProjectName
}

# For each test in the profile, invoke the pester tests
Write-Output "Running on $Cloud using Subscription $SubscriptionName under the $EnvironmentName environment for the $ProjectName Project"

# Example (base it on Cloud value)
Invoke-Pester -Script $Cloud\rg.Tests.ps1 $SubscriptionName $ResourceName $ResourceLocation $ResourceTags
