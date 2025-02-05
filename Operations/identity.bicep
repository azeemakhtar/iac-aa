
@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

param teamName string

module holdingfundscreening '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-holdingfundscreening-${environment}-${buildNumber}'
  params: {
    appName: 'holdingfundscreening'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module cairofundscreening '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-cairofundscreening-${environment}-${buildNumber}'
  params: {
    appName: 'cairofundscreening'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module depreciationserviceapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-depreciationserviceapi-${environment}-${buildNumber}'
  params: {
    appName: 'depreciationserviceapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module msciinstrumentadapterservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-msciinstrumentadapterservice-${environment}-${buildNumber}'
  params: {
    appName: 'msciinstrumentadapterservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module cairocncfee '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-cairocncfee-${environment}-${buildNumber}'
  params: {
    appName: 'cairocncfee'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module msci '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-msci-${environment}-${buildNumber}'
  params: {
    appName: 'msci'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module fundscreening '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-fundscreeningservice-api-${environment}-${buildNumber}'
  params: {
    appName: 'fundscreeningservice-api'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module reqopsservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-reqopsservice-${environment}-${buildNumber}'
  params: {
    appName: 'reqopsservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module operationsDbmigration '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-operations-dbmigration-${environment}-${buildNumber}'
  params: {
    appName: 'operations-dbmigration'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module tiger '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-tiger-${environment}-${buildNumber}'
  params: {
    appName: 'tiger'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module esgService '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-esgservice-${environment}-${buildNumber}'
  params: {
    appName: 'esgservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module personalaccountdealingservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-personalaccountdealingservice-${environment}-${buildNumber}'
  params: {
    appName: 'personalaccountdealingservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module eodpriceProxyService '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-eodprice-proxy-${environment}-${buildNumber}'
  params: {
    appName: 'eodprice-proxy'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output cairocncfeePrincipalId string = cairocncfee.outputs.principalId
output cairofundscreeningPrincipalId string = cairofundscreening.outputs.principalId
output eodpriceProxyServicePrincipalId string = eodpriceProxyService.outputs.principalId
output esgServicePrincipalId string = esgService.outputs.principalId
output fundscreeningServiceApiPrincipalId string = fundscreening.outputs.principalId
output holdingfundscreeningPrincipalId string = holdingfundscreening.outputs.principalId
output msciinstrumentadapterservicePrincipalId string = msciinstrumentadapterservice.outputs.principalId
output msciPrincipalId string = msci.outputs.principalId
output operationsDbMigrationPrincipalId string = operationsDbmigration.outputs.principalId
output personalaccountdealingservice string = personalaccountdealingservice.outputs.principalId
output reqopsservicePrincipalId string = reqopsservice.outputs.principalId
output tigerPrincipalId string = tiger.outputs.principalId

output principalIds array = [
  cairocncfee.outputs.principalId
  cairofundscreening.outputs.principalId
  depreciationserviceapi.outputs.principalId
  eodpriceProxyService.outputs.principalId
  esgService.outputs.principalId
  fundscreening.outputs.principalId
  holdingfundscreening.outputs.principalId
  msci.outputs.principalId
  msciinstrumentadapterservice.outputs.principalId
  operationsDbmigration.outputs.principalId
  personalaccountdealingservice.outputs.principalId
  reqopsservice.outputs.principalId
  tiger.outputs.principalId
]
