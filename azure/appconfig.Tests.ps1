param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure App Configuration" {
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
                # Error out with Resource Group Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the App Configurations in the Resource Group
        $Resources = Get-AzAppConfigurationStore -ResourceGroupName $ResourceGroupName

        It "App Configuration should exist in expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific App Configuration
        $Resource = Get-AzAppConfigurationStore -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "App Configuration should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "App Configuration should be of the expected SKU" {
            $Resource.SKUName | Should -Be $ResourceSKU
        }

        It "App Configuration should have all the expected Resource Tags" {
            $ResourceFound = $false
            $Message = "Resource"
            $CompareKeys = Compare-Object -ReferenceObject $Resource.Tags.Keys -DifferenceObject $ResourceTags.Keys
            if ( -not ($CompareKeys)) {
                $CompareValues = Compare-Object -ReferenceObject $Resource.Tags.Values -DifferenceObject $ResourceTags.Values
                if ( -not ($CompareValues)) {
                    $ResourceFound = $true
                    $Message = $Message + " is Found."
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
        # Get specific App Configuration
        $Resource = Get-AzAppConfigurationStore -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "App Configuration should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    AfterAll {
    }
}