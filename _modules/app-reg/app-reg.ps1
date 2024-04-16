param(
    [String] $AppName
)
Connect-AzureAD -TenantId '904e2f8f-5832-43bf-aea8-7cbfde1c5d4c'
#$sp = Get-AzADServicePrincipal - ServicePrincipalName  "groupextensionservice-test"
$sp = Get-AzADApplication -DisplayName $AppName | Get-AzADServicePrincipal
# $jsonTemplate = @{
#     name = $name
#     issuer = $Issuer;
#     subject = "system:serviceaccount:"  +   $app.teamNamespace + ":" + $ServiceName;
#     description = "";
#     audiences =  @('api://AzureADTokenExchange');
# }


#     $azApp = az ad sp create-for-rbac --display-name $name | ConvertFrom-Json
#     Write-Output $azApp.appId

#     $azOwner = az ad user show --id $Owner | ConvertFrom-Json

#     Write-Output $azOwner.id

#     az ad app owner add --id $azApp.appId --owner-object-id $azOwner.id

#     ConvertTo-Json -Compress $jsonTemplate | Out-File ".\config.json"
#     $federation = az ad app federated-credential list --id $azApp.appId | ConvertFrom-Json
#     Write-Host $federation.Count

#     if ($federation.Count -eq 0)
#     {
#         Write-Host 'creating federation'
#         az ad app federated-credential create --id $azApp.appId  --parameters "config.json"
#     } else
#     {
#         Write-Host 'updating federation'
#         az ad app federated-credential update --id $azApp.appId --federated-credential-id $jsonTemplate.name --parameters "config.json"
#     }
#     $servicePrincipal = az ad sp show --id $azApp.appId  | ConvertFrom-Json
#Write-Output $sp.Id
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['objectId'] = $sp.Id
$DeploymentScriptOutputs['appId'] = $sp.AppId