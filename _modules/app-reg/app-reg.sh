az login --service-principal -u $clientId -p $clientSercret --tenant $tenantId
application=$(az ad sp list --display-name groupextensionservice-test)
application=$(jq '.[0]' <<< "$application")
echo $application
applicationObjectId=$(jq -r '.id' <<< "$application")
applicationClientId=$(jq -r '.appId' <<< "$application")
echo $applicationClientId
outputJson=$(jq -n --arg applicationObjectId "$applicationObjectId" --arg applicationClientId "$applicationClientId" '{objectId: $applicationObjectId, appId: $applicationClientId}' )
echo $outputJson > $AZ_SCRIPTS_OUTPUT_PATH