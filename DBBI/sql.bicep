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

param subnetId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator ad group id of the team.')
param admGroupId string

@description('Team resource name')
param teamName string

param firewallRules array = []

#disable-next-line no-hardcoded-env-urls
var serverName = 'sql-bi-${environment}-weu'
var admGroumName = 'az-grp-${teamName}-${environment}-sqladmin'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      login: admGroumName
      sid: admGroupId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: false
      principalType: 'Group'
    }
    publicNetworkAccess: 'Enabled'
  }
  resource sqlFirewall 'firewallRules@2023-05-01-preview' = [for firewallRule in firewallRules: {
    name: firewallRule.name
    properties: {
      startIpAddress: firewallRule.startIpAddress
      endIpAddress: firewallRule.endIpAddress
    }
  }]
}

var databaseName = 'sqldb-auditbi-${environment}-weu'
module sqlDB '../_modules/sql/sqldb.bicep' = {
  name: '${databaseName}-${buildNumber}'
  params: {
    sqlServerName: sqlServer.name
    environment: environment
    dbName: databaseName
    location: location
    skuName: 'S2'
    storageInBytes: -1
  }
}

module sqlPrivateEndpoint '../_modules/network/privateendpoint.bicep' = {
  name: '${serverName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: serverName
    location: location
    groupIds: [
      'sqlServer'
    ]
    resourceId: sqlServer.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.database.windows.net')
module sqlPrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${serverName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: sqlPrivateEndpoint.outputs.privateEndpointName
  }
}
