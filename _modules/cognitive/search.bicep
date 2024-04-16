@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@description('Team resource name')
param teamName string

param searchIndexDataReaders array = []
param searchIndexDataContributors array = []
param searchServiceContributors array = []

var searchServiceName = 'srch-${teamName}-${environment}-weu'

resource searchService 'Microsoft.Search/searchServices@2022-09-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: false
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    hostingMode: 'default'
    networkRuleSet: {
      ipRules: []
    }
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    publicNetworkAccess: 'disabled'
    partitionCount: 1
    replicaCount: 1
  }
}

module searchPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${searchServiceName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: searchServiceName
    location: location
    groupIds: [
      'searchService'
    ]
    resourceId: searchService.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.search.windows.net')
module searchPrivateDns '../network/privateDns.bicep' = {
  name: '${searchServiceName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: searchPrivateEndpoint.outputs.privateEndpointName
  }
}

module searchIndexDataReader '../identity/roleAssignment.bicep' = [for principalId in searchIndexDataReaders: {
  name: '${principalId}-searchuser-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'SearchIndexDataReader'
  }
}]

module searchIndexDataContributor '../identity/roleAssignment.bicep' = [for principalId in searchIndexDataContributors: {
  name: '${principalId}-searchindexcontr-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'SearchIndexDataContributor'
  }
}]

module searchServiceContributor '../identity/roleAssignment.bicep' = [for principalId in searchServiceContributors: {
  name: '${principalId}-searchservicecontr-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'SearchServiceContributor'
  }
}]

output searchServiceName string = searchService.name
