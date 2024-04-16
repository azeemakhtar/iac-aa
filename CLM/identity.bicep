@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string

module groupextensionservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-groupextensionservice-${environment}-${buildNumber}'
  params: {
    appName: 'groupextensionservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module dependencyfinder '../_modules/identity/workloadidentity.bicep' = if (environment == 'dev') {
  name: 'wid-${teamName}-dependencyfinder-${environment}-${buildNumber}'
  params: {
    appName: 'dependencyfinder'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module selfserviceportal '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-selfserviceportal-${environment}-${buildNumber}'
  params: {
    appName: 'selfserviceportal'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module selfserviceapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-selfserviceapi-${environment}-${buildNumber}'
  params: {
    appName: 'selfserviceapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module bisnodeadapterapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-bisnodeadapterapi-${environment}-${buildNumber}'
  params: {
    appName: 'bisnodeadapterapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module trapetsadapterapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-trapetsadapterapi-${environment}-${buildNumber}'
  params: {
    appName: 'trapetsadapterapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module clientlifecycleservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-clientlifecycleservice-${environment}-${buildNumber}'
  params: {
    appName: 'clientlifecycleservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module clientportal '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-clientportal-${environment}-${buildNumber}'
  params: {
    appName: 'clientportal'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module dbmigration '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-sql-migrator-${environment}-${buildNumber}'
  params: {
    appName: 'sql-migrator'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module taskmanagementservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-task-management-${environment}-${buildNumber}'
  params: {
    appName: 'task-management'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module formsService '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-formsservice-${environment}-${buildNumber}'
  params: {
    appName: 'formsservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output bisnodeAdapterApiPrincipalId string = bisnodeadapterapi.outputs.principalId
output clientLifecycleServicePrincipalId string = clientlifecycleservice.outputs.principalId
output clientPortalPrincipalId string = clientportal.outputs.principalId
output dependencyFinderPrincipalId string = environment == 'dev' ? dependencyfinder.outputs.principalId : ''
output formsServicePrincipalId string = formsService.outputs.principalId
output groupExtensionservicePrincipalId string = groupextensionservice.outputs.principalId
output selfServiceApiPrincipalId string = selfserviceapi.outputs.principalId
output selfServicePortalPrincipalId string = selfserviceportal.outputs.principalId
output sqlMigratorPrincipalId string = dbmigration.outputs.principalId
output taskManagementPrincipalId string = taskmanagementservice.outputs.principalId
output trapetsAdapterApiPrincipalId string = trapetsadapterapi.outputs.principalId


output clmIds array = [
  bisnodeadapterapi.outputs.principalId
  clientlifecycleservice.outputs.principalId
  clientportal.outputs.principalId
  dbmigration.outputs.principalId
  formsService.outputs.principalId
  groupextensionservice.outputs.principalId
  selfserviceapi.outputs.principalId
  selfserviceportal.outputs.principalId
  taskmanagementservice.outputs.principalId
  trapetsadapterapi.outputs.principalId
]
