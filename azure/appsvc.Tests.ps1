param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceKind,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][string]$ResourceURI,
    [Parameter(Mandatory)][string]$ResourceAppType,
    [Parameter(Mandatory)][string]$ResourceVersion,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure App Service" {

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
        # Get all the App Services in the Resource Group
        $Resources = Get-AzAppService -ResourceGroupName $ResourceGroupName

        It "App Service should exist in the expected Resource Group" {
            $ResourceFound = $false

            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                    break
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific App Service
        $Resource = Get-AzAppService -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "App Service should be of the expected Kind" {
            $Resource.Kind | Should -Be $ResourceKind
        }

        It "App Service should be of the expected SKU" {
            $Resource.SkuName | Should -Be $ResourceSKU
        }

        It "App Service should have all the expected Resource Tags" {
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
        # Get specific App Service
        $Resource = Get-AzAppService -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "App Service should be Enabled" {
            $Resource.Enabled | Should -Be "True"
        }

        It "App Service should be in Running State" {
            $Resource.State | Should -Be "Running"
        }

        It "App Service should be Active and Listening to Requests" {
            $ResourceActive = Invoke-WebRequest -Uri $ResourceURI
            $ResourceActive.StatusCode | Should -Be "200"
        }

        It "App Service should return the expected version" {
            $AppURL = (Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName).DefaultHostName
            $AppRespond = Invoke-WebRequest -Uri $AppURL/Version
            # TO DO: Check the respose type to extract the version and replace the version property
            $AppRespond.Version | Should -Be $ResourceVersion
        }
    }

    AfterAll {
    }
}