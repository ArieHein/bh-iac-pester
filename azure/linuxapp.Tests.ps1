param (
    [Parameter(Mandatory)][string]$SubscriptionName,
    [Parameter(Mandatory)][string]$ResourceName,
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$ResourceLocation,
    [Parameter(Mandatory)][string]$ResourceKind,
    [Parameter(Mandatory)][string]$ResourceSKU,
    [Parameter(Mandatory)][string]$ResourceURI,
    [Parameter(Mandatory)][hashtable]$ResourceTags
)

Describe "Azure Linux Web App" {

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
        # Get all linux Web Apps in the ResourceGroup
        $Resources = Get-AzAppService -ResourceGroupName $ResourceGroupName

        It "AppService should exist in Resource Group" {
            $ResourceFound = $false
            foreach ($Resource in $Resources) {
                if ($Resource.Name -eq $ResourceName) {
                    $ResourceFound = $true
                }
            }
            $ResourceFound | Should -Be $true
        }

        # Get specific linux Web App
        $Resource = Get-AzAppService -Name $ResourceName -ResourceGroupName $ResourceGroupName

        It "AppService should be of expected Kind" {
            $Resource.Kind | Should -Be $ResourceKind
        }

        It "AppService is of the expected SKU" {
            $Resource.SkuName | Should -Be $ResourceSKU
        }

        It "AppService should have all Resource Tags" {
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
        # Get specific linux Web App
        $Resource = Get-AzAppService -Name $ResourceName -ResourceGroupName $ResourceGroupName

        # Check if App Service is Enabled
        It 'Should be Enabled' {
            $Resource.Enabled | Should Be "True"
        }

        # Check if App Service is in Running state
        It 'Should be Running State' {
            $Resource.State | Should Be "Running"
        }

        # Check App Service is listening to requests
        It "AppService should be active" {
            $ResourceActive = Invoke-WebRequest -Uri $ResourceURI
            $ResourceActive | Should -Be "200"
        }

        # Check App Service Version returns desired version
        It 'Should return desired version' {
            $AppURL = (Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName).DefaultHostName
            $AppRespond = Invoke-WebRequest -Uri $AppURL/Version
            # TO DO: Check the respose type to extract the version and replace the version property
            $AppRespond.Version | Should Be $AppVersion 
        }
    }

    AfterAll {
    }
}