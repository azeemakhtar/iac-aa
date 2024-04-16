param location string = resourceGroup().location
param environment string = 'test'
param buildNumber string
param subnetId string
param teamName string
param Sku object = {
  name: 'Standard'
  tier: 'Standard'
}


var servicebus_name = 'sbns-${teamName}-${environment}-weu'
resource servicebus_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: servicebus_name
  location: location
  properties: {
    disableLocalAuth: false
    minimumTlsVersion: '1.2'
    premiumMessagingPartitions: 0
    publicNetworkAccess: 'Disabled'
    zoneRedundant: false
  }
  sku: Sku
}

resource servicebus_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: servicebus_resource
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource servicebus_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2022-10-01-preview' = {
  parent: servicebus_resource
  name: 'default'
  properties: {
    defaultAction: 'Allow'
    publicNetworkAccess: 'Disabled'
    trustedServiceAccessEnabled: false
  }
}

module sbPrivateEndpoint '../_modules/network/privateendpoint.bicep' = {

  name: '${servicebus_name}-privateendpoint-${buildNumber}'
  params: {
    resourceName: servicebus_name
    location: location
    groupIds: [
      'namespace'
    ]
    resourceId: servicebus_resource.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.servicebus.windows.net')
module redisPrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${servicebus_name}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: sbPrivateEndpoint.outputs.privateEndpointName
  }
}
