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
                # Error out with ResourceGroup Not Found.
            }
        }
    }

    Context "Resource Provision" {
        # Get all the SQL DBs in the ResourceGroup
        $Resources = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName

        It "SQL Database should exist in expected SQL Server" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific SQLDB
        $Resource = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName -DatabaseName $ResourceName

        # Check SQLDatabase is in the desired Location
        It 'Should be in Location' {
            $Resource.Location | Should -Be $SQLDatabaseLocation
        }

        # Check SQLDatabase is in desrired Edition
        It 'Should have desired Edition' {
            $Resource.Edition | Should -Be $SQLDatabaseEdition
        }

        # Check SQLDatabase is of desired Family
        It 'Should be desired SQL Database family' {
            $Resource.Family | Should -Be $SQLDatabaseFamily
        }

        # Check SQLDatabase is of desired Collation
        It 'Should be desired SQL Database family' {
            $Resource.CollationName | Should -Be $SQLDatabaseCollation
        }

        it "Should have expected SQL Database Name" {
            $Resource.Name | Should -Be $ResourceName
        }

        it "Should have expected SQL Database Capacity" {
            $Resource.Capacity | Should -Be $ResourceCapacity
        }

        it "Should be exepcted SQL Database Family" {
            $Resource.Family | Should -Be $ResourceFamily
        }

        it "Should be expected SQL Database Edition" {
            $Resource.Edition | Should -Be $ResourceEdition
        }

        it "Shold be expected SQL Database Max Size" {
            $Resource.MaxSizeByte  | Should -Be $ResourceMaxSize # 1073741824
        }

        # Validate SQLDB Tags

    }

    Context "Resource Operation" {
        # Get specific SQL Database
        $Resource = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ResourceServerName -DatabaseName $ResourceName

        # Check SQL Database is in desired Status
        It 'Should be in expected SQL Database status' {
            $Resource.Status | Should Be "Online"
        }
    }

    AfterAll {
    }
}