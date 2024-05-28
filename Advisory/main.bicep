@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([
  'dev'
  'test'
  'preprod'
  'prod'
])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Sql databases for team advisory')
param sqlDatabases array

@description('Sql admin ad group for sql server')
param sqlAdmGroup string

param identityVerificationId string

@description('App insight environment settings')
param appInsightEnvironementSettings object


var teamName = 'advisory'
var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'
var admTeamSid = '51a0281a-6730-4b16-99f7-269d81769f6f'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vnet
}

module identity 'identity.bicep' = {
  name: 'identity-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
  }
}

module keyvault '../_modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    adminPrincipalIds: [ admTeamSid ]
    userPrincipalIds: identity.outputs.advisoryIds
  }
}

module sqlServer '../_modules/sql/sql.bicep' = {
  name: 'sqldb-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    admGroupId: sqlAdmGroup
    databases: [for database in sqlDatabases: {
      name: 'sqldb-${database.name}-${environment}-weu'
      skuName: database.skuName
    }]
  }
}

module sqlAlerts '../_modules/sql/sql-alerts.bicep' = {
  name: 'sqldbalerts-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    teamName: teamName
    location: location
  }
}

module storage '../_modules/storage/storageaccount.bicep' = {
  name: 'storage-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'identityver'
    buildNumber: buildNumber
    subnetId: subnet.id
    teamSid: admTeamSid
  }
}

module blob '../_modules/storage/blob.bicep' = {
  name: 'blobidentityverification-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'blob-identityverification-${environment}'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: [
      identityVerificationId
      identity.outputs.identityverificationPrincipalId
    ]
  }
}

module sourcemaps '../_modules/storage/storageaccount.bicep' = {
  name: 'st-${teamName}-sourcemaps-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'sourcemaps'
    buildNumber: buildNumber
    subnetId: subnet.id
    teamSid: admTeamSid
  }
}

module sourceMapsBlob '../_modules/storage/blob.bicep' = {
  name: 'blobsourceMapsBlob-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'blob-sourcemaps-${environment}'
    stoAccountName: sourcemaps.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: [
    ]
  }
}

module appinsights '../_modules/applicationinsights/applicationinsights.bicep' = {
  name: 'appinsights-${teamName}-${environment}-${buildNumber}'
  params: {
    teamName: teamName
    location: location
    environment: environment
    dailyCap: appInsightEnvironmentSettings[environment].dailyCap
    logRetention: 90
  }
}
