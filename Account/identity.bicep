@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string

module accountholdinginformationservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-accountholdinginformationservice-${environment}-${buildNumber}'
  params: {
    appName: 'accountholdinginformationservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module accounttransactions '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-accounttransactions-${environment}-${buildNumber}'
  params: {
    appName: 'accounttransactions'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module brokerGroups '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-broker-group-${environment}-${buildNumber}'
  params: {
    appName: 'broker-group'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}
module customerteams '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-customer-teams-${environment}-${buildNumber}'
  params: {
    appName: 'customer-teams'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output accountholdinginformationservicePrincipalId string = accountholdinginformationservice.outputs.principalId
output accounttransactionsPrincipalId string = accounttransactions.outputs.principalId
output brokerGroupPrincipalId string = brokerGroups.outputs.principalId
output customerteamsPrincipalId string = customerteams.outputs.principalId
output principalIds array = [
  accountholdinginformationservice.outputs.principalId
  accounttransactions.outputs.principalId
  brokerGroups.outputs.principalId
  customerteams.outputs.principalId
]
