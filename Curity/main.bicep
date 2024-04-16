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

@description('Sql databases for team enabler')
param sqlDatabases array

@description('Sql admin ad group for sql server')
param sqlAdmGroup string

var teamName = 'curity'
var admTeamSid = '1b9d9bfd-0831-4834-9b78-9069fdc2c55d' // team enabler

var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'

var environmentConfig = {
  dev: {
    curity: '9020e358-4974-4261-a29b-64f35244ec00'
  }
  test: {
    curity: '4b9ebf46-9a04-412f-898b-b2a7b6501df3'
  }
  preprod: {
    curity: '1d0505c9-8def-4922-9dca-abdf020d67d5'
  }
  prod: {
    curity: 'e0378d93-5d64-4ec1-8490-b4faadabdb17'
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
  environmentConfig[environment].curity
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

module sqlServer '../_modules/sql/sql.bicep' = {
  name: 'sqldb-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    admGroupId: sqlAdmGroup
    databases: [for database in sqlDatabases:  {
      name: 'sqldb-${database.name}-${environment}-weu'
      skuName: database.skuName
    }]
  }
}

module storage '../_modules/storage/storageaccount.bicep' = {
  name: 'storage-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'curity'
    buildNumber: buildNumber
    subnetId: subnet.id
    usedAsFileShare: true
    usedAsBlob: false
  }
}

module fileshare '../_modules/storage/fileshare.bicep' = {
  name: 'fileshare-${teamName}-${environment}-${buildNumber}'
  params: {
    shareName: 'share-curity-${environment}'
    stoAccountName: storage.outputs.stoName
  }
}
