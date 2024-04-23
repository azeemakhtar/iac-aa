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

param databases array

param azureADOnlyAuthentication bool = true

#disable-next-line no-hardcoded-env-urls
var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.database.windows.net')
var serverName = 'sql-${teamName}-${environment}-weu'
var admGroumName = 'az-grp-${teamName}-${environment}-sqladmin'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  properties: {
    administrators:{
      administratorType: 'ActiveDirectory'
      login: admGroumName
      sid: admGroupId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: azureADOnlyAuthentication
      principalType: 'Group'
    }
    publicNetworkAccess: 'Disabled'
  }
}

module sqlDB 'sqldb.bicep' = [for database in databases:  {
  name: '${database.name}-${buildNumber}'
  params: {
    sqlServerName: sqlServer.name
    environment: environment
    dbName: database.name
    location: location
    skuName: database.skuName
    storageInBytes: database.storageInBytes
  }
}]

module sqlPrivateEndpoint '../network/privateendpoint.bicep' = {
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

module sqlPrivateDns '../network/privateDns.bicep' = {
  name: '${serverName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: sqlPrivateEndpoint.outputs.privateEndpointName
  }
}
