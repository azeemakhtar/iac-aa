@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

var teamName = 'chatcib'

var admTeamSid = '611cac2d-14f0-4388-91fc-790320d0f9c1' // Team Infrastructure

var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vnet
}

module managedIdentities 'identity.bicep' = {
  name: 'id-k8s-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    tenantName: 'chatcib'
    buildNumber: buildNumber
  }
}

var chatcibjobId = managedIdentities.outputs.chatcibjobPrincipalId
var chatcibwebId = managedIdentities.outputs.chatcibwebPrincipalId

module keyVault '../_modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    adminPrincipalIds: [admTeamSid]
    userPrincipalIds: [ 
        chatcibwebId 
     ]
  }
}

module storage './storage.bicep' = {
  name: 'st-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
    subnetId: subnet.id
    storageBlobDataContributors: [
      chatcibjobId
      chatcibwebId
    ]
  }
}

module openAi '../_modules/cognitive/openai.bicep' = {
  name: 'oai-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
    subnetId: subnet.id
    deployments: [
      {
        name: 'chat'
        model: {
          name: 'gpt-35-turbo'
          version: '0301'
        }
        capacity: 120
      }
      {
        name: 'embedding'
        model: {
          name: 'text-embedding-ada-002'
          version: '2'
        }
        capacity: 120
      }
    ]
    cognitiveServicesOpenAIUsers: [
      chatcibwebId
    ]
  }
}

module search '../_modules/cognitive/search.bicep' = {
  name: 'srch-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
    subnetId: subnet.id
    searchIndexDataReaders: [
      openAi.outputs.openAiPrincipalId
    ]
    searchIndexDataContributors: [
      chatcibjobId
    ]
    searchServiceContributors: [
      chatcibjobId
    ]
  }
}


module formRecognizer '../_modules/cognitive/formrecognizer.bicep' = {
  name: 'cog-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
    subnetId: subnet.id
    cognitiveServicesUsers: [
      chatcibjobId
    ]
  }
}

module cosmosDb 'database.bicep' = {
  name:'cosmos-db-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    environment: environment
    subnetId: subnet.id
    teamName: teamName
    location: location
    documentDBAccountContributors: [
      chatcibwebId
    ]
  }
}

module secrets 'secrets.bicep' = {
  name: 'secrets-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    cosmosName: cosmosDb.outputs.cosmosName
    keyVaultName: keyVault.outputs.keyValutName
    openAiName: openAi.outputs.openAiName
    searchName: search.outputs.searchServiceName
  }
}
