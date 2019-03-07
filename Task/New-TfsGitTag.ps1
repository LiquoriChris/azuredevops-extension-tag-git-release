param (
    [Parameter(Mandatory)]
    [string]$Name,
    [Parameter(Mandatory)]
    [string]$Message,
    [string]$PersonalAccessToken
)

function _Authentication {
    param (
        [string]$PersonalAccessToken
    )

    if ($PersonalAccessToken) {
        @{
            Authorization = "Basic $PersonalAccessToken"
        }
    }
    else {
        @{
            Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
        }
    }
}

if (!$env:SYSTEM_ACCESSTOKEN -and !$PersonalAccessToken) {
    throw "Enable access token is not available for $env:RELEASE_ENVIRONMENTNAME"
}
else {
    $Params = @{}
    if ($PersonalAccessToken) {
        $Params.PersonalAccessToken = $PersonalAccessToken
    }
    $Headers = _Authentication @Params
}

$Params = @{
    Uri = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI$env:BUILD_PROJECTNAME/_apis/git/repositories/$env:BUILD_REPOSITORY_ID/annotatedtags?api-version=5.0-preview.1"
    Headers = $Headers
    Body = [ordered]@{
        name = $Name
        taggedObject = @{
            objectId = $env:BUILD_SOURCEVERSION
        }
        message = $Message
    } |ConvertTo-Json -Depth 2
    ContentType = 'application/json'
    Method = 'Post'
    ErrorAction = 'Stop'
}
Try {
    $Response = Invoke-RestMethod @Params
}
Catch {
    throw $_
}

Write-Output "Name: $($Response.name)"
Write-Output "Commit: $($Response.objectId)"
Write-Output "Message: $($Response.message)"