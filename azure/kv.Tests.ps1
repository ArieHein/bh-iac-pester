param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][bool]$ResourceDeploy,
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
                # Error out with ResourceGroup Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the Key Vaults in the ResourceGroup
        $Resources = Get-AzKeyVault -ResourceGroupName $ResourceGroupName

        It "KeyVault should exist in Resource Group" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.VaultName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -be $true
        }

        # Get specific Key Vault
        $Resource = Get-AzKeyVault -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "KeyVault should be of expected SKU" {
            $Resource.Sku | Should -Be $ResourceSKU
        }

        It "KeyVault should have expected Enabeld for Deployment setting" {
            $Resource.EnabledForDeployment | Should -Be $ResourceDeploy
        }

        # Validate Key Vault Tags

    }

    Context "Resource Operation" {
    }

    AfterAll {
    }
}