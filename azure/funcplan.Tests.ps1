param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceWorkerType,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][string]$ResourceStatus,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure FunctionApp Plan" {

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
        # Get all the Function App Plans in the Resource Group
        $Resources = Get-AzFunctionAppPlan -ResourceGroupName $ResourceGroupName

        It "Function App Plan should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Function App Plan
        $Resource = Get-AzFunctionAppPlan -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Function App Plan should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Function App Plan should be of the expected SKU" {
            $Resources.SkuName | Should -Be $ResourceSKU
        }

        It "Function App Plan should be of the expected Worker Type" {
            $Resource.Worker | Should -Be $ResourceWorkerType
        }

        It "Function App Plan should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
         # Get specific Function App Plan
        $Resource = Get-AzContainerRegistry -Name $ResourceName -ResourceGroupName $ResourceGroupName
    
        It "Function App Plan should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }

        It "Function App Plan should be at expected state" {
            $Resource.Status | Should -Be $ResourceStatus
        }
    }

    AfterAll {
    }
}