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

@description('SqlDatabases for team')
param sqlDatabases array

@description('Sql admin ad group for sql server')
param sqlAdmGroup string

var teamName = 'credit'
var admTeamSid = '884cf343-0ab9-4473-9100-0fae87311f43' //az-grp-dep-Team Credit-Admin

var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'

var environmentConfig = {
  dev: {
    standardCollateralRatioImportJob: '9094fa72-434b-45cf-bd39-74fa1803173d'
  }
  test: {
    standardCollateralRatioImportJob: '0a2661fc-7480-47a3-8412-4ea6251ae6dc'
  }
  preprod: {
    standardCollateralRatioImportJob: 'e3b2b5f9-81c3-422a-99fe-b8f6c5af901d'
  }
  prod: {
    standardCollateralRatioImportJob: 'a82e573a-e40b-4cd0-8f5f-830cb0d284c9'
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
    buildNumber: buildNumber
    location: location
    environment: environment
    teamName: teamName
  }
} 

var kvAccessAppRegistrations = [
  environmentConfig[environment].standardCollateralRatioImportJob
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
module database '../_modules/sql/sql.bicep' = {
  name: 'database-${teamName}-${environment}-${buildNumber}'
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

module sqlAlerts '../_modules/sql/sql-alerts.bicep' = {
  name: 'sqldbalerts-${teamName}-${environment}-${buildNumber}'
  params:{
    environment: environment
    teamName: teamName
    location: location
  }
}
