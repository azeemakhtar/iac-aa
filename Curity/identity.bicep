@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string
module curity '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-curity-${environment}-${buildNumber}'
  params: {
    appName: 'curity'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output curityPrincipalId string = curity.outputs.principalId
output principalIds array = [
  curity.outputs.principalId
]
