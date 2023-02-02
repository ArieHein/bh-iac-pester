param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceVersion,
    [Parameter(Mandatory)][bool]$ResourceCheckDB = $false,
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
            $ResourceFound | Should -Be $true
        }

        # Get specific SQLServer
        $Resource = Get-AzSqlServer -ServerName $ResourceName -ResourceGroupName $ResourceGroupName

        # Check SQLServer is in the desired location
        It 'SQLServer should be in expected Location' {
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

        # Check SQLServer is active
        # Since there is no way via powershell or the API to look at server status
        # The way to implement a check is by actually connecting to the master db.
        # Evaluate $ResourceCheckDB, which by default is false, but if you supply $true
        # it should run a connection attempt to the fully qualified dns name of the sql server
        # to the master db. There isnt even a need to run a query. One thing to think is how
        # to connect from agent doing the tests, as it require adding IP to the SQL FW Rules
        # can always try adding, testing and removing ot perhaps if it record this as
        # an azure service and 0.0.0.0 already appears in the sql fw rules but ofc only if it comes
        # from Azure DevOps.

    }

        # Think about adding test to actually connect to test connection string

        AfterAll {
    }
}