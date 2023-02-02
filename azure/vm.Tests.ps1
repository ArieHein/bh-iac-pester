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
                # Error out with ResourceGroup Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the VMs in the ResourceGroup
        $Resources = Get-AzVM -ResourceGroupName $ResourceGroupName | 

        It "VM should exist in Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -Be $true
        }
        
        # Get specific VM
        $Resource = Get-AzVM -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "VM should be" {

        }

        # Validate VM Tags

    }

    Context "Resource Operation" {
        # Get specific VM
        $Resource = Get-AzVM -Name $ResourceName -ResourceGroupName $ResourceGroupName

        # Check VM is in the desired Provisioning State
        It 'Should be in desired Provisioning State' {
            $Resource.ProvisioningState | Should Be "Succeedded"
        }
    }

    AfterAll {
    }
}