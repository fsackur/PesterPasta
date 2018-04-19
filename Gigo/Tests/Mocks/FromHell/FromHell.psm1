<#
    An awful API client from hell.
#>

function Get-SatanicData {

    [CmdletBinding(DefaultParameterSetName = 'GetLostSouls')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'CondemnSoulToHell')]
        [ValidateSet('John Milton', 'Gandhi', 'People who drop litter')]
        [ValidateLength(6, 52)]
        [ValidateScript({$true})]
        [ValidatePattern('^\w')]
        [string]$Soul,

        [Parameter(Mandatory = $true, ParameterSetName = 'GetLocationOfHell')]
        [switch]$GetLocation
    )

    if ($PSCmdlet.ParameterSetName -eq 'GetLocationOfHell')
    {
        $Url = 'https://icanhazip.com'
    }
    else
    {
        $Url = "https://beel.z.bub/api"  #Even Satan uses transport layer security
    }

    if ($Soul)
    {
        Invoke-RestMethod "$Url$Soul" -Method Post
    }
    else
    {
        Invoke-RestMethod $Url
    }
}