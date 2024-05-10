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

@description('Location for all resources')
param location string = resourceGroup().location

var teamName = 'enabler'
var admTeamSid = '1b9d9bfd-0831-4834-9b78-9069fdc2c55d'
var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'
var environmentConfig = {
  dev: {
    grafana: '9ae186f0-6a44-4970-b76f-a748cfda9466'
  }
  test: {
    grafana: 'bc1d41d4-4039-4a39-b38b-f2b6280cdd80'
  }
  preprod: {
    grafana: 'dd8c2a2a-b3c5-49e2-bcc5-5f1f9c6299d2'
  }
  prod: {
    grafana: '801e7cd3-5725-4c2b-91b4-a4e21f43d790'
  }
}
var appInsightEnvironmentSettings = {
  dev: {
    dailyCap: 2
  }
  test: {
    dailyCap: 2
  }
  preprod: {
    dailyCap: 2
  }
  prod: {
    dailyCap: 10
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: subnetName
  parent: vnet
}

module identity 'identity.bicep' = {
  name: 'identity-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    buildNumber: buildNumber
    teamName: teamName
  }
} 

var kvAccessAppRegistrations = [
  environmentConfig[environment].grafana
]

module keyvault '../_modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    adminPrincipalIds: [
      admTeamSid
    ]
    userPrincipalIds: union(kvAccessAppRegistrations, identity.outputs.principalIds)
  }
}

module storage '../_modules/storage/storageaccount.bicep' = {
  name: 'storage-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'grafana'
    buildNumber: buildNumber
    subnetId: subnet.id
    usedAsFileShare: true
    usedAsBlob: false
  }
}

module fileshare '../_modules/storage/fileshare.bicep' = {
  name: 'fileshare-${teamName}-${environment}-${buildNumber}'
  params: {
    shareName: 'share-grafana-${environment}'
    stoAccountName: storage.outputs.stoName
  }
}

module appinsights '../_modules/applicationinsights/applicationinsights.bicep' = {
  name: 'appinsights-${teamName}-${environment}-${buildNumber}'
  params: {
    teamName: teamName
    location: location
    environment: environment
    dailyCap: appInsightEnvironmentSettings[environment].dailyCap
    logRetention: 90
  }
}
