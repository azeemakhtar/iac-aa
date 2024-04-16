@description('Build number to use for tagging deployments')
param buildNumber string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Team resource name')
param teamName string

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@allowed([ 'GlobalDocumentDB', 'MongoDB', 'Parse' ])
param kind string

var cosmosName = 'cosmos-${teamName}-${environment}-weu'
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosName
  location: location
  kind: kind
  properties: {
    publicNetworkAccess: 'Disabled'
    virtualNetworkRules: []
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'AzureServices'
    minimalTlsVersion: 'Tls12'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: { defaultConsistencyLevel: 'Session' }
    capabilities: []
    ipRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    disableLocalAuth: false
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

module cosmosPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${cosmosName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: cosmosName
    location: location
    groupIds: [
      'Sql'
    ]
    resourceId: cosmos.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.documents.azure.com')
module cosmosPrivateDns '../network/privateDns.bicep' = {
  name: '${cosmosName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: cosmosPrivateEndpoint.outputs.privateEndpointName
  }
}

output cosmosName string = cosmos.name
