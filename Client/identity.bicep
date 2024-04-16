@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string
module accountPerformance '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-account-performance-${environment}-${buildNumber}'
  params: {
    appName: 'account-performance'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module instrumentMonitoring '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-instrument-monitoring-${environment}-${buildNumber}'
  params: {
    appName: 'instrument-monitoring'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module curityauthenticationadapter '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-curityauthenticationadapter-${environment}-${buildNumber}'
  params: {
    appName: 'curityauthenticationadapter'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module manageradmin '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-manageradmin-${environment}-${buildNumber}'
  params: {
    appName: 'manageradmin'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module pbonline '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-pbonline-${environment}-${buildNumber}'
  params: {
    appName: 'pbonline'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output accountPerformancePrincipalId string = accountPerformance.outputs.principalId
output instrumentMonitoringPrincipalId string = instrumentMonitoring.outputs.principalId
output curityAuthenticationAdapterPrincipalId string = curityauthenticationadapter.outputs.principalId
output manageradminPrincipalId string = manageradmin.outputs.principalId
output pbonlinePrincipalId string = pbonline.outputs.principalId
output principalIds array = [
  accountPerformance.outputs.principalId
  instrumentMonitoring.outputs.principalId
  curityauthenticationadapter.outputs.principalId
  manageradmin.outputs.principalId
  pbonline.outputs.principalId
]
