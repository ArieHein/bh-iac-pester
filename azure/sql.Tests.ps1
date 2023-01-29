param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceVersion,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

# Potentially add a way to test login with user name and password taken from keyvault

Describe "Azure SQL Server" {

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
        # Get all the SQLServers in the ResourceGroup
        $Resources = Get-AzSqlServer -ResourceGroupName $ResourceGroupName

        It "SQLServer should exist in Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.ServerName -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -be $true
        }

        # Get specific SQLServer
        $Resource = Get-AzSqlServer -ServerName $ResourceName -ResourceGroupName $ResourceGroupName

        # Check SQLServer is in the desired location
        It 'SQLServer should be in Location' {
            $Resource.Location | Should -Be $ResourceLocation
        }

        # Check SQL Server Version
        It "SQLServer should be of expected Version" {
            $Resource.ServerVersion | Should -Be $ResourceVersion
        }

        # Validate SQLServer Tags
    }

    Context "Resource Operation" {
        # Get specific SQLServer
        $Resource = Get-AzSqlServer -ServerName $ResourceName -ResourceGroupName $ResourceGroupName

        # Check SQLServer is in desrired state
        It 'Should have Running State' {
            $Resource.Status | Should Be $SQLServerStatus
        }
    }

        # Think about adding test to actually connect to test connection string

        AfterAll {
    }
}