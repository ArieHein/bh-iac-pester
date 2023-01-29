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
        # Get all Subscriptions in the connection context, to be sure all commands
        # are executed in the correct Subscription.
        $Subscriptions = Get-AzContext -ListAvailable
        foreach ($Subscription in $Subscriptions) {
            if ($Subscription.SubscriptionName -eq $SubscriptionName) {
                Set-AzContext -Subscription $SubscriptionName
            }
            else {
                # Error out with Subscription Not Found. Note that by default only 25
                # Subscriptions will show up. Use Connect-AzAccount -MaxContextPopulation <int> to get more context
            }
        }
        $ResourceGroups = Get-AzResourceGroup
        foreach ($ResourceGroup in $ResourceGroups) {
            if ( -not ($ResourceGroup.Name -eq $ResourceGroupName)) {
                # Error out with ResourceGroup Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the Storage Accouts in the Resource Group
        $Resources = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName

        It "Storage Account should exist in the Resource Group" {
            $ResourceFound = $false
            $Resources | ForEach-Object {
                if (_$.StorageAccountName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific Storage Account
        $Resource = Get-AzStorageAccount -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Storage Account should be in Location" {
            $Resource.PrimaryLocation | Should -Be $ResourceLocation
        }

        It "Storage Account Should be of Tier" {
            $Resource.SKU.Tier | Should -Be $ResourceTier
        }

        It "Storage Account Should be of expected Replication" {
            $Resource.Replication | Should -Be $ResourceReplic
        }

        It "Storage Account Should have expected Pubilc Access" {
            $Resource.AllowBlobPublicAccess | Should -Be $ResourcePublic
        }

        It "Storage Account Should be of desired TLS" {
            $Resource.MinimumTlsVersion | Should -Be $ResourceTLS
        }

        It "Storage Account Should be in desired HttpTrafic setting" {
            $Resource.EnableHttpsTrafficOnly | Should -Be $ResourceHTTPSOnly
        }

        It "ResourceGroup should have all Resource Tags" {
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