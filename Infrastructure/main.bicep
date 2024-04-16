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

@description('Sql databases for team advisory')
param sqlDatabases array

@description('Sql admin ad group for sql server')
param sqlAdmGroup string

var teamName = 'infrastructure'
var shortName = 'infra'

var admTeamSid = '611cac2d-14f0-4388-91fc-790320d0f9c1'

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

module keyvault '../_modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-${shortName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: shortName
    adminPrincipalIds: [
      admTeamSid
    ]
    userPrincipalIds: []
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
