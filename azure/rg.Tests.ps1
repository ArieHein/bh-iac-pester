param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Resource Group" {

    BeforeAll {
        # Get all Subscriptions in the connection context, to be sure all commands
        # are executed in the correct Subscription.
        $Subscriptions = Get-AzContext -ListAvailable

        $Subscriptions | ForEach-Object {
            if (_$.SubscriptionName -eq $SubscriptionName) {
                Set-AzContext -Subscription $SubscriptionName
                break
            }
            else {
                # Error out with Subscription Not Found. Note that by default only 25
                # Subscriptions will show up. Use Connect-AzAccount -MaxContextPopulation <int> to get more context
            }
        }
    }

    Context "Resource Provision" {
        # Get all the Resource Groups in the Subscription
        $Resources = Get-AzResourceGroup -Subscription $SubscriptionName

        It "Resource Group should exist in the expected Subscription" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.ResourceGroupName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Resource Group
        $Resource = Get-AzResourceGroup -Name $ResourceName -Subscription $SubscriptionName

        It "Resource Group should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Resource Group should have all the expected Resource Tags" {
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
        # Get specific Resource Group
        $Resource = Get-AzResourceGroup -Name $ResourceName -Subscription $SubscriptionName

        It "Resource Group should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    AfterAll {
    }
}