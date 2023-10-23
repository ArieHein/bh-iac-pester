param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceTier,
    [Parameter(Mandatory)][string]$ResourceReplic,
    [Parameter(Mandatory)][bool]$ResourcePublic,
    [Parameter(Mandatory)][string]$ResourceTLS,
    [Parameter(Mandatory)][bool]$ResourceHTTPSOnly,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)
Describe "Azure Storage Account" {
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
        # Get all the Storage Accounts in the Resource Group
        $Resources = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName

        It "Storage Account should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Storage Account
        $Resource = Get-AzStorageAccount -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Storage Account should be in the expected Location" {
            $Resource.PrimaryLocation | Should -Be $ResourceLocation
        }

        It "Storage Account should be of the expected Tier" {
            $Resource.SKU.Tier | Should -Be $ResourceTier
        }

        It "Storage Account should have the expected Replication setting" {
            $Resource.Replication | Should -Be $ResourceReplic
        }

        It "Storage Account should have the expected Pubilc Access setting" {
            $Resource.AllowBlobPublicAccess | Should -Be $ResourcePublic
        }

        It "Storage Account should have the exepcted TLS setting" {
            $Resource.MinimumTlsVersion | Should -Be $ResourceTLS
        }

        It "Storage Account should have the expected HttpTrafic setting" {
            $Resource.EnableHttpsTrafficOnly | Should -Be $ResourceHTTPSOnly
        }

        It "Storage Account should have all the expected Resource Tags" {
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
        $Resource = Get-AzStorageAccount -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Storage Account should be provisioned successfully" {
            $Resource.ProvisioningState | Should -Be "Succeeded"
        }
    }

    AfterAll {
    }
}