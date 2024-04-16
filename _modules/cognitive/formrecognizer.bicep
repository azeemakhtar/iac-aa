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

param cognitiveServicesUsers array = []

var formRecognizerName = 'cog-${teamName}-${environment}-weu'

resource formRecognizer 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: formRecognizerName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'FormRecognizer'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    disableLocalAuth: false
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
    customSubDomainName: formRecognizerName
  }
}

module frPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${formRecognizerName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: formRecognizer.name
    location: location
    groupIds: [
      'account'
    ]
    resourceId: formRecognizer.id
    subnetId: subnetId
  }
}

var frPrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.cognitiveservices.azure.com')
module frPrivateDns '../network/privateDns.bicep' = {
  name: '${formRecognizerName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: frPrivateDnsZoneId
    privateEndpointName: frPrivateEndpoint.outputs.privateEndpointName
  }
}

module cognitiveServicesUser '../identity/roleAssignment.bicep' = [for principalId in cognitiveServicesUsers: {
  name: '${principalId}-cogservicesuser-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'CognitiveServicesUser'
  }
}]

output formRecognizerName string = formRecognizer.name
