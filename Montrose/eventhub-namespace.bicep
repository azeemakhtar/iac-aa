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

@description('EventHubs SKU')
param sku object

param eventHubsReceivers array = []
param eventHubsSenders array = []

var eventHubNamespaceName = 'evhns-${teamName}-${environment}-weu'
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: sku.name
    tier: sku.tier
    capacity: sku.capacity
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: false
    zoneRedundant: false
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
 }


module eventHubNamespacePrivateEndpoint '../_modules/network/privateendpoint.bicep' = {
  name: '${eventHubNamespace.name}-privateendpoint-${buildNumber}'
  params: {
    resourceName: eventHubNamespace.name
    location: location
    groupIds: [
      'namespace'
    ]
    resourceId: eventHubNamespace.id
    subnetId: subnetId
  }
}

var eventHubNamespacePrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.servicebus.windows.net')
module eventHubNamespacePrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${eventHubNamespace.name}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: eventHubNamespacePrivateDnsZoneId
    privateEndpointName: eventHubNamespacePrivateEndpoint.outputs.privateEndpointName
  }
}

module azureEventHubsDataReceiver '../_modules/identity/roleAssignment.bicep' = {
  name: 'evh-datareceiver-${buildNumber}'
  params: {
    principalIds: eventHubsReceivers
    roleName: 'AzureEventHubsDataReceiver'
    }
  }

  module azureEventHubsDataSender '../_modules/identity/roleAssignment.bicep' = { 
    name: 'evh-datawriter-${buildNumber}'
    params: {
      principalIds: eventHubsSenders
      roleName: 'AzureEventHubsDataSender'
    }
  }


output eventHubNamespaceName string = eventHubNamespace.name

