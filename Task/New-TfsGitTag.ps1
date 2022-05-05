[CmdletBinding()]
param ()

$OAuthToken = Get-VstsTaskVariable -Name System.AccessToken
$Environment = Get-VstsTaskVariable -Name System.PhaseName
$TeamUri = Get-VstsTaskVariable -Name System.TeamFoundationCollectionUri
$ProjectName = Get-VstsTaskVariable -Name System.TeamProject
$RepositoryId = Get-VstsTaskVariable -Name Build.Repository.Id
$SourceVersion = Get-VstsTaskVariable -Name Build.SourceVersion
$Name = Get-VstsInput -Name 'Name' -Default false
$Message = Get-VstsInput -Name 'Message' -Default false
$IgnoreExisting = Get-VstsInput -Name 'ignoreExisting' -Default $false
$PersonalAccessToken = Get-VstsInput -Name 'PersonalAccessToken'

function _Authentication {
    param (
        [string]$PersonalAccessToken
    )

    if ($PersonalAccessToken) {
        $PersonalAccessToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $UserName, $PersonalAccessToken)))
        @{
            Authorization = "Basic $PersonalAccessToken"
        }
    }
    else {
        @{
            Authorization = "Bearer $OAuthToken"
        }
    }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (!$PersonalAccessToken -and !$OAuthToken) {
    throw ("There is no authentication method provided. Please use a personal access token or allow OAuth token to be used for $Environment")
}
else {
    $Params = @{}
    if ($PersonalAccessToken) {
        $Params.PersonalAccessToken = $PersonalAccessToken
    }
    $Headers = _Authentication @Params
}

$Params = @{
    Uri = "$($TeamUri)$($ProjectName)/_apis/git/repositories/$($RepositoryId)/annotatedtags?api-version=5.0-preview.1"
    Headers = $Headers
    Body = [ordered]@{
        name = $Name
        taggedObject = @{
            objectId = $SourceVersion
        }
        message = $Message
    } |ConvertTo-Json -Depth 2
    ContentType = 'application/json'
    Method = 'Post'
    ErrorAction = 'Stop'
}

$TagCreated = $false
Try {
    $Response = Invoke-RestMethod @Params
    Write-Output "Name: $($Response.name)"
    Write-Output "Commit: $($Response.taggedObject.objectId)"
    Write-Output "Message: $($Response.message)"
    $TagCreated = $true
}
Catch {
    $throw = $true
    $StatusCode = $_.Exception.Response.StatusCode.value__
    if (($StatusCode -eq 409) -and ($IgnoreExisting)) {
        Write-Warning "Tag '$Name' already exists. Ignoring."
        $throw = $false
    }
    if ($throw) {
        throw $_
    }
}

exit($TagCreated)
