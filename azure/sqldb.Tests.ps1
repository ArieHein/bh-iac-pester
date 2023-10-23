param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceServerName,
    [Parameter(Mandatory)][string]$ResourceEdition,
    [Parameter(Mandatory)][string]$ResourceCollation,
    [Parameter(Mandatory)][string]$ResourceMaxSize,
    [Parameter(Mandatory)][string]$ResourceCapacity,
    [Parameter(Mandatory)][string]$ResourceSKUName,
    [Parameter(Mandatory)][string]$ResourceCurrentObjective,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure SQL Database" {
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
        # Get all the SQL Databasess in the Resource Group and SQL Server
        $Resources = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName

        It "SQL Database should exist in the expected Resource Group and SQL Server" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific SQL Database
        $Resource = Get-AzSqlDatabase -DatabaseName $ResourceName -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName

        It "SQL Database should be in expected Location" {
            $Resource.Location | Should -Be $ResourceLocation
        }

        It "SQL Database should have the expected Collation setting" {
            $Resource.CollationName | Should -Be $ResourceCollation
        }

        it "SQL Database should have the expected Capacity setting" {
            $Resource.Capacity | Should -Be $ResourceCapacity
        }

        it "SQL Database should be of the expected Edition" {
            $Resource.Edition | Should -Be $ResourceEdition
        }

        it "SQL Database shold have the expected Max Size setting" {
            $Resource.MaxSizeByte  | Should -Be $ResourceMaxSize # 1073741824
        }

        It "SQL Database should have all the expected Resource Tags" {
        }
    }

    Context "Resource Operation" {
        # Get specific SQL Database
        $Resource = Get-AzSqlDatabase -DatabaseName $ResourceName -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName

        It "SQL Database should be in expected status" {
            $Resource.Status | Should -Be "Online"
        }
    }

    AfterAll {
    }
}