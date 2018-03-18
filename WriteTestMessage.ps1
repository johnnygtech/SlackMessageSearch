$WebhookRoot = "https://hooks.slack.com/services/"
$uniqueUrlEndpoint = $(Get-Content ./secrets/relativeUrl.txt) #post message incoming webhook in test channel
$WebhookUrl = "$webHookRoot$uniqueUrlEndpoint"

$TextPayload = @{
    "source"="TestComputer1";
    "audience"="TestComputer2";
    "command"="Get-Process"
}

$payload = @{

    "text"=$(ConvertTo-Json $TextPayload)

}

Invoke-RestMethod -Method POST -Uri $WebhookUrl -Body $(ConvertTo-Json $payload)

. ./secrets/oauth.ps1

<#
the oauth file is a list of four variables used to generate an oauth token:
$clientId = 
$secret = 
$token = 
$oauth = 
#>

$searchUrl = "https://slack.com/api/search.messages"

$body = @{
    "token"=$oauth;
    "query"="Computer"
}
$query = Invoke-RestMethod -Uri $searchUrl -Method POST -Body $body
$query.Messages.maches.text

$TextPayload = @{
    "source"="TestComputer2";
    "audience"="TestComputer1";
    "command"="ipconfig"
}

$payload = @{

    "text"=$(ConvertTo-Json $TextPayload)

}

Invoke-RestMethod -Method POST -Uri $WebhookUrl -Body $(ConvertTo-Json $payload)

$body = @{
    "token"=$oauth;
    "query"="ipconfig"
}
$query = Invoke-RestMethod -Uri $searchUrl -Method POST -Body $body
$query.Messages.maches.text

$body = @{
    "token"=$oauth;
    "query"="audience"
}
$query = Invoke-RestMethod -Uri $searchUrl -Method POST -Body $body
$query.Messages.matches.text
$query.Messages.Matches | %{
    $notJson = ConvertFrom-Json $($_.text)
    $notJson | ?{$_.audience -eq "TestComputer2"} | %{& $_.command}
}
