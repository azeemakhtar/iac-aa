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

@description('Sql databases')
param sqlDatabases array

@description('Sql admin ad group for sql server')
param sqlAdmGroup string

@description('SignalR SKU')
param signalRSku object

@allowed([ 'Free', 'Basic', 'Standard' ])
param nftnsSku string

var teamName = 'montrose'
var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'
var admTeamSid = '3d6f8597-950d-42ba-97bd-6326c30d3416'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vnet
}

module identity './identity.bicep' = {
  name: 'identity-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    location: location
    environment: environment
    teamName: teamName
  }
}

module keyvault './keyvault.bicep' = {
  name: 'keyvault-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    admTeamSid: admTeamSid
    userPrincipalIds: identity.outputs.montroseIds
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
    azureADOnlyAuthentication: false
    databases: [for database in sqlDatabases: {
      name: 'sqldb-${database.name}-${environment}-weu'
      skuName: database.skuName
      storageInBytes: contains(database, 'storageInBytes') ? database.storageInBytes : -1
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

module redis 'redis.bicep' = {
  name: 'redis-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    teamName: teamName
    location: location
    buildNumber: buildNumber
    subnetId: subnet.id
    redisContribuiters: [ 
      identity.outputs.marketdataId
    ]
  }
}

module signalR 'signalr.bicep' = {
  name: 'sigr-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    teamName: teamName
    location: location
    buildNumber: buildNumber
    subnetId: subnet.id
    sku: signalRSku
    signalRContribuiters: [ identity.outputs.marketdataId ]
  }
}

module eventHubNamespace 'eventhub-namespace.bicep' = {
  name: 'evhns-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    buildNumber: buildNumber
    subnetId: subnet.id
    teamName: teamName
    location: location
    eventHubsReceivers: [
      identity.outputs.marketdataId
      identity.outputs.priceHistoryId
    ]
    eventHubsSenders: [ identity.outputs.marketdataFeederId ]
  }
}

module eventHub 'eventhub.bicep' = {
  name: 'evhs-${teamName}-${environment}-${buildNumber}'
  params: {
    eventHubNamespaceName: eventHubNamespace.outputs.eventHubNamespaceName
  }
}

module storage './storage.bicep' = {
  name: 'storage-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    buildNumber: buildNumber
    subnetId: subnet.id
    teamName: teamName
    storageBlobDataContributors: [
      identity.outputs.marketdataId
      identity.outputs.priceHistoryId
    ]
  }
}

module nftns 'notificationhub.bicep' = {
  name: 'nftns-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    location: location
    sku: nftnsSku
  }
}
