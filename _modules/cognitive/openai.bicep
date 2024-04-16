@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Build number to use for tagging deployments')
param buildNumber string

@description('Team resource name')
param teamName string

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@description('')
param deployments array = []

param cognitiveServicesOpenAIUsers array = []

var openAiName = 'oai-${teamName}-${environment}-weu'

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiName
  location: location
  sku: {
    name: 'S0' 
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
    customSubDomainName: openAiName
  }
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: openAi
  name: deployment.name
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.model.name
      version: deployment.model.version
    }
  }
  sku: {
    name: 'Standard'
    capacity: deployment.capacity
  }
}]


module openAiPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${openAiName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: openAi.name
    location: location
    groupIds: [
      'account'
    ]
    resourceId: openAi.id
    subnetId: subnetId
  }
}

var openAiPrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.openai.azure.com')
module openAiPrivateDns '../network/privateDns.bicep' = {
  name: '${openAi.name}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: openAiPrivateDnsZoneId
    privateEndpointName: openAiPrivateEndpoint.outputs.privateEndpointName
  }
}

module cognitiveServicesOpenAIUser '../identity/roleAssignment.bicep' = [for principalId in cognitiveServicesOpenAIUsers: {
  name: '${principalId}-openaiuser-${buildNumber}'
  params: {
    principalId: principalId
    roleName: 'CognitiveServicesOpenAIUser'
  }
}]

output openAiName string = openAi.name
output openAiPrincipalId string = openAi.identity.principalId
