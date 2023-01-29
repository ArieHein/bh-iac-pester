param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceWorker,
    [Parameter(Mandatory)][string]$ResourceSKUName,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Function App Plan" {

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
        # Get all the Function App Plans in the ResourceGroup
        $Resources = Get-AzFunctionAppPlan -ResourceGroupName $ResourceGroupName

        It "FuncAppPlan should exist in Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Function App Plan
        $Resource = Get-AzFunctionAppPlan -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "FuncAppPlan should have expected Kind" {

        }

        It "FuncAppPlan should have expected Tier" {

        }

        It "FuncAppPlan should have expected Size" {

        }

        It "FuncAppPlan should have expected Capacity" {

        }

        # Validate FunAppPlan Tags

    }

    Context "Resource Operation" {
    }

    AfterAll {
    }
}