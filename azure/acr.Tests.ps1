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
                # Error out with Resource Group Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the Container Registries in the Resource Group
        $Resources = Get-AzContainerRegistry -ResourceGroupName $ResourceGroupName

        It "Container Registry should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Container Registry
        $Resource = Get-AzContainerRegistry -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Container Registry should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Container Registry should have the expected AdminEnabled setting" {
            $Resource.AdminUserEnabled | Should -Be $ResourceAdmin
        }

        It "Container Registry should be of the expected SKU" {
            $Resource.SkuName | Should -Be $ResourceSKU
        }

        It "Container Registry should have all the expected Resource Tags" {
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
        # Get specific Container Registry
        $Resource = Get-AzContainerRegistry -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Container Registry should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    # test for curl on the registry URL. Potentially with checking Login if its enabled

    AfterAll {
    }
}