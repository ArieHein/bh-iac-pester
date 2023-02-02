param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Key Vault" {
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
        # Get all the Key Vaults in the Resource Group
        $Resources = Get-AzKeyVault -ResourceGroupName $ResourceGroupName

        It "Key Vault should exist in the Resource Group" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.VaultName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Key Vault
        $Resource = Get-AzKeyVault -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Key Vault should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "Key Vault should be of the expected SKU" {
            $Resource.Sku | Should -Be $ResourceSKU
        }

        It "Key Vault should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
    }

    AfterAll {
    }
}