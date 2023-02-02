param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceKind,
    [Parameter(Mandatory)][bool]$ResourceWKS,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Application Insights" {

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
        # Get all Application Insights in the ResourceGroup
        $Resources = Get-AzApplicationInsights -ResourceGroupName $ResourceGroupName

        It "Application Insights should exist in Resource Group" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Application Insight
        $Resource = Get-AzApplicationInsights -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Application Insights should be in expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Application Insights should be of expected Kind" {
            $Resource.Kind | Should -Be $ResourceKind
        }

        It "Application Insights should be of expected type" {
            $Resource.WorkspaceResourceId | Should -Be $ResourceWKS
        }

        It "Application Insights should have all Resource Tags" {
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
        # Get specific Application Insights
        $Resource = Get-AzApplicationInsights -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Application Insights should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    AfterAll {
    }
}