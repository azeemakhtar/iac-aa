@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string
module grafana '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-grafana-${environment}-${buildNumber}'
  params: {
    appName: 'grafana'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output grafanaPrincipalId string = grafana.outputs.principalId
output principalIds array = [
  grafana.outputs.principalId
]
