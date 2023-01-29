param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][bool]$ResourceAdmin,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Container Registry" {
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
        # Get all the Container Registries in the ResourceGroup
        $Resources = Get-AzContainerRegistry -ResourceGroupName $ResourceGroupName

        It "ACR should exist in Resource Group" {
            $ResourceFound = $false
            
            $Resources | ForEach-Object {
                if (_$.RegistryName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Container Registry
        $Resource = Get-AzContainerRegistry -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "ACR should be in expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "ACR should have expected AdminEnabled setting" {
            $Resource.AdminUserEnabled | Should -Be $ResourceAdmin
        }

        It "ACR should be of the required SKU" {
            $Resource.SkuName | Should -Be $ResourceSKU
        }

        It "ACR should have all Resource Tags" {
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
        # Get specific Container Registry
        $Resource = Get-AzContainerRegistry -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Resource Group should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

        # test for curl on the registry URL. Potentially with checking Login if its enabled

    AfterAll {

    }
}