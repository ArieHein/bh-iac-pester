param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][string]$ResourceScaleUnit,
    [Parameter(Mandatory)][string]$ResourcePublicIP,
    [Parameter(Mandatory)][string]$ResourceVNetName,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Bastion" {
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
        # Get all the Bastions in the Resource Group
        $Resources = Get-AzBastion -ResourceGroupName $ResourceGroupName

        It "Bastion should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Bastion
        $Resource = Get-AzBastion -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Bastion should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Bastion should be of the expected SKU" {
            $Resource.Sku | Should -Be $ResourceSKU
        }

        It "Bastion should be of the expected ScaleUnit" {
            $Resource.ScaleUnit | Should -Be $ResourceScaleUnit
        }

        It "Bastion should be of the expected Public IP" {
            $Resource.IPConfiguration.PublicIPAddress.Id | Should -Be $ResourcePublicIP
        }

        It "Bastion should have all the expected Resource Tags" {
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
        # Get specific Bastion
        $Resource = Get-AzBastion -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Bastion should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    AfterAll {
    }
}