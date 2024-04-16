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

var teamName = 'account'
var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'
var admTeamSid = 'bb0a82e2-8d49-4ec4-af47-310306eed56c'
//var admTeamName = 'az-grp-dep-Team Account-Admin'

var environmentConfig = {
  dev: {
    accountHoldingInformationServiceId: 'd1c93c05-5e79-4ad5-916e-b9b95eebb34e'
    accountTransactionsServiceId: '33f37aae-4544-4c64-9b62-b8990f32ac04'
    brokerGreoupServiceId: '096603fa-08d6-4ec0-adb5-6921275df858'
  }
  test: {
    accountHoldingInformationServiceId: '746e23c1-47be-40e9-9e0a-375db7dcb31f'
    accountTransactionsServiceId: 'bdc72d5c-eff0-4073-a376-6022eede2dd6'
    brokerGreoupServiceId: '8cd70828-9b4c-4cf5-8a44-14b1bb1d9bf1'
  }
  preprod: {
    accountHoldingInformationServiceId: '23a3f105-4a16-48cc-86b6-1e736a084b56'
    accountTransactionsServiceId: 'b1a0dd57-bc9f-4d0b-8eae-94db25a07e3b'
    brokerGreoupServiceId: '0a3e9e8d-ee85-49cf-a9d8-eee11641918f'
  }
  prod: {
    accountHoldingInformationServiceId: 'a3575c95-aae1-47d3-aa0e-650d37db31a5'
    accountTransactionsServiceId: 'b70e8680-c198-4530-a441-5973ed638229'
    brokerGreoupServiceId: '8d586a01-c512-4339-a4a1-419ad21b2725'
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

module keyvault '../_modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnet.id
    location: location
    environment: environment
    teamName: teamName
    adminPrincipalIds: [ admTeamSid ]
    userPrincipalIds: union([
        environmentConfig[environment].accountHoldingInformationServiceId
        environmentConfig[environment].accountTransactionsServiceId
        environmentConfig[environment].brokerGreoupServiceId
      ], identity.outputs.principalIds)
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
    databases: [for database in sqlDatabases: {
      name: 'sqldb-${database.name}-${environment}-weu'
      skuName: database.skuName
    }]
  }
}

module sqlAlerts '../_modules/sql/sql-alerts.bicep' = {
  name: 'sqldbalerts-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    teamName: teamName
    location: location
  }
}
