param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceKind,
    [Parameter(Mandatory)][string]$ResourceTier,
    [Parameter(Mandatory)][string]$ResourceSize,
    [Parameter(Mandatory)][string]$ResourceCapacity,
    [Parameter(Mandatory)][string]$ResourceWorkers,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Service Plan" {

    BeforeAll {
        $Subscriptions = Get-AzContext -ListAvailable
        foreach ($Subscription in $Subscriptions) {

            if ($Subscription.SubscriptionName -eq $SubscriptionName) {
                Set-AzContext -Subscription $SubscriptionName
            }
            else {
                # Error out with Subscription Not Found. Note that by default only 25 Subscriptions
                # will show up. Use Connect-AzAccount -MaxContextPopulation <int> to get more context
            }
        }

        $ResourceGroups = Get-AzResourceGroup -Subscription $SubscriptionName

        foreach ($ResourceGroup in $ResourceGroups) {

            if ( -not ($ResourceGroup.Name -eq $ResourceGroupName)) {
                # Error out with ResourceGroup Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all Service Plans in the ResourceGroup
        $Resources = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName

        It "Service Plan should exist in Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Service Plan
        $Resource = Get-AzAppServicePlan -Name $ResourceName -ResourceGroupName $ResourceGroupName

        # Check Service Plan is in the desired location
        It 'Service Plan should be in Location' {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Service Plan should have expected Kind" {
            $Resource.Kind | Should -Be $ResourceKind
        }

        It "Service Plan should have expected Tier" {
            $Resource.Sku.Tier | Should -Be $ResourceTier
        }

        It "Service Plan should have expected Size" {
            $Resource.Sku.Size | Should -Be $ResourceSize
        }

        It "Service Plan should have expected Capacity" {
            $Resource.Sku.Capacity | Should -Be $ResourceCapacity
        }

        It "Service Plan should have expected Number of Workers" {
            $Resource.MaximumNumberOfWorkers | Should -Be $ResourceWorkers
        }

        # Validate Service Plan Tags
        It "Service Plan should have all Resource Tags" {
            $ResourceFound = $false
            $Message = "Resource is"
            $CompareKeys = Compare-Object -ReferenceObject $Resource.Tags.Keys -DifferenceObject $ResourceTags.Keys
            if ( -not ($CompareKeys)) {
                $CompareValues = Compare-Object -ReferenceObject $Resource.Tags.Values -DifferenceObject $ResourceTags.Values
                if ( -not ($CompareValues)) {
                    $ResourceFound = $true
                    $Message = $Message + " Found."
                }
                else {
                    $Message = $Message + " is not found. Keys equal, Values are not."
                }
            }
            else {
                $Message = $Message + " is not found. Keys are not equal."
            }
            $ResourceFound | Should -Be $true
        }
    }

    Context "Resource Operation" {
        # Get specific Service Plan
        $Resource = Get-AzAppServicePlan -Name $ResourceName -ResourceGroupName $ResourceGroupName

        # Check status of Provisioning
        It 'Service Plan Should have ProvisioningState Succeeded' {
            $Resource.ProvisioningState | Should Be "Succeeded"
        }

        # Check status of Plan
        It 'Service Plan Should have Ready Status' {
            $Resource.Status | Should Be "Ready"
        }
    }

    AfterAll {
    }
}