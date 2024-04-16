@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string
module standardcollateralratioimportJob '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-standardcollateralratioimport-job-${environment}-${buildNumber}'
  params: {
    appName: 'standardcollateralratioimport-job'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}
module creditactivityservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-creditactivityservice-${environment}-${buildNumber}'
  params: {
    appName: 'creditactivityservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}
module creditdbmigration '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-creditdbmigration-${environment}-${buildNumber}'
  params: {
    appName: 'creditdbmigration'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'sql-migrator'
  }
}

output standardCollateralRatioImportJobPrincipalId string = standardcollateralratioimportJob.outputs.principalId
output creditactivityservicePrincipalId string = creditactivityservice.outputs.principalId
output creditdbmigrationPrincipalId string = creditdbmigration.outputs.principalId
output principalIds array = [
  standardcollateralratioimportJob.outputs.principalId
  creditactivityservice.outputs.principalId
  creditdbmigration.outputs.principalId
]
