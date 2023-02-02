param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceVersion,
    [Parameter(Mandatory)][bool]$ResourceCheckDB = $false,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

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
                # Error out with Resource Group Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the SQL Servers in the Resource Group
        $Resources = Get-AzSqlServer -ResourceGroupName $ResourceGroupName

        It "SQL Server should exist in the expected Resource Group" {
            $ResourceFound = $false

            $Resources | ForEach-Object {
                if (_$.ServerName -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific SQL Server
        $Resource = Get-AzSqlServer -ServerName $ResourceName -ResourceGroupName $ResourceGroupName

        It "SQL Server should be in the expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "SQL Server should be of expected Version" {
            $Resource.ServerVersion | Should -Be $ResourceVersion
        }

        It "SQL Server should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
        # Get specific SQL Server
        $Resource = Get-AzSqlServer -ServerName $ResourceName -ResourceGroupName $ResourceGroupName

        # Check SQLServer is active
        # Since there is no way via powershell or the API to look at server status
        # The way to implement a check is by actually connecting to the master db.
        # Evaluate $ResourceCheckDB, which by default is false, but if you supply $true
        # it should run a connection attempt to the fully qualified dns name of the sql server
        # to the master db. There isnt even a need to run a query. One thing to think is how
        # to connect from agent doing the tests, as it require adding IP to the SQL FW Rules
        # can always try adding, testing and removing ot perhaps if it record this as
        # an azure service and 0.0.0.0 already appears in the sql fw rules but ofc only if
        # it comes from Azure DevOps.
    }

    AfterAll {
    }
}