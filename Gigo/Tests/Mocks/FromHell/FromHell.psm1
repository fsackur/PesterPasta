<#
    An awful API client from hell.
#>

function Get-SatanicData {

    [CmdletBinding(DefaultParameterSetName = 'GetLostSouls')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'CondemnSoulToHell')]
        [string]$Soul
    )

    $Url = "https://beel.z.bub/api"  #Even Satan uses transport layer security

    if ($Soul)
    {
        Invoke-RestMethod "$Url$Soul" -Method Post
    }
    else
    {
        Invoke-RestMethod $Url
    }
}