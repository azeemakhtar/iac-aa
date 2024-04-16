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
param teamName string

param redisContribuiters array = []

@description('Location for all resources')
param location string = resourceGroup().location
param subnetId string
var redisCacheName = 'redis-${teamName}-${environment}-weu'

resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisCacheName
  location: location
  properties: {
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    sku: {
      capacity: 1
      family: 'C'
      name: 'Basic'
    }
    redisConfiguration: {
      'maxmemory-reserved': '125'
      'maxfragmentationmemory-reserved': '125'
      'aad-enabled': 'True'
      'maxmemory-delta': '125'
    }
    publicNetworkAccess: 'Disabled'
  }
}

resource accessPolicy 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' = [ for id in redisContribuiters: {
  name: 'ap-${id}'
  parent: redisCache
  properties: {
    accessPolicyName: 'Data Contributor'
    objectId: id
    objectIdAlias: id
  }
}]


module redisPrivateEndpoint '../_modules/network/privateendpoint.bicep' = {
  name: '${redisCacheName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: redisCacheName
    location: location
    groupIds: [
      'redisCache'
    ]
    resourceId: redisCache.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.redis.cache.windows.net')
module redisPrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${redisCacheName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: redisPrivateEndpoint.outputs.privateEndpointName
  }
}
