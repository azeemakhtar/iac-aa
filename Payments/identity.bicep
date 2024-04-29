
@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

param teamName string

module paymentsproxy '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-paymentsproxy-${environment}-${buildNumber}'
  params: {
    appName: 'paymentsproxy'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output paymentsproxyPrincipalId string = paymentsproxy.outputs.principalId

output principalIds array = [
  paymentsproxy.outputs.principalId
]
