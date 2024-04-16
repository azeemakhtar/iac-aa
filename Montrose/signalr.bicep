@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Team resource name')
param teamName string

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@description('Build number to use for tagging deployments')
param buildNumber string

@description('SignalR SKU')
param sku object

param signalRContribuiters array = []


var signalRName = 'sigr-${teamName}-${environment}-weu'
resource signalR 'Microsoft.SignalRService/signalR@2023-02-01' = {
  name: signalRName
  location: location
  sku: {
    capacity: 1
    name: sku.name
    tier: sku.tier
  }
  kind: 'SignalR'
  properties: {
    disableAadAuth: false
    disableLocalAuth: false
    features: [
      {
        flag: 'ServiceMode'
        value: 'Default'
        properties: {}
      }
      {
        flag: 'EnableConnectivityLogs'
        value: 'True'
        properties: {}
      }
      {
        flag: 'EnableMessagingLogs'
        value: 'False'
        properties: {}
      }
      {
        flag: 'EnableLiveTrace'
        value: 'False'
        properties: {}
      }
    ]
    networkACLs: {
      defaultAction: 'deny'
      privateEndpoints: []
      publicNetwork: {}
    }
    publicNetworkAccess: 'Disabled'
    serverless: {
      connectionTimeoutInSeconds: 30
    }
    tls: {
      clientCertEnabled: false
    }
    upstream: {}
  }
}

module redisContribuiter '../_modules/identity/roleAssignment.bicep' = [for principalId in signalRContribuiters: {
  name: '${principalId}-sigcontribuitors-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'SignalRWebPubSubContributor'
  }
}]


module signalRAppServer '../_modules/identity/roleAssignment.bicep' = [for principalId in signalRContribuiters: {
  name: '${principalId}-appserver-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'SignalRAppServer'
  }
}]

module signalRPrivateEndpoint '../_modules/network/privateendpoint.bicep' = {
  name: '${signalR.name}-privateendpoint-${buildNumber}'
  params: {
    resourceName: signalR.name
    location: location
    groupIds: [
      'signalr'
    ]
    resourceId: signalR.id
    subnetId: subnetId
  }
}

var signalRPrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.service.signalr.net')
module signalRPrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${signalR.name}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: signalRPrivateDnsZoneId
    privateEndpointName: signalRPrivateEndpoint.outputs.privateEndpointName
  }
}
