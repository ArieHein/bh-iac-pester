param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceFuncType,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Function App" {
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
        # Get all the Function Apps in the Resource Group
        $Resources = Get-AzFunctionApp -ResourceGroupName $ResourceGroupName
        
        It "Function App should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Function App
        $Resource = Get-AzFunctionApp -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Function App should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Function App should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
    }

    AfterAll {
    }
}