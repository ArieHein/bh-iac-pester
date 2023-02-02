param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceOSType,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Virtual Machine" {

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
        # Get all the VirtualMachines in the Resource Group
        $Resources = Get-AzVM -ResourceGroupName $ResourceGroupName | 

        It "Virtual Machine should exist in the expected Resource Group" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }
        
        # Get specific Virtual Machine
        $Resource = Get-AzVM -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Virtual Machine should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }
    
        It "Virtual Machine should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
        # Get specific Virtual Machine
        $Resource = Get-AzVM -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "Virtual Machine should be provisioned successfully" {
            $Resource.ProvisioningState | Should Be "Succeedded"
        }
    }

    AfterAll {
    }
}