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

var teamName = 'payments'
var shortTeamName = 'payments'
// var vnetRgName = 'rg-vnet-${environment}-weu'
// var vnetName = 'vnet-${environment}-weu'
// var subnetName = 'snet-${teamName}-${environment}-weu'
// var admTeamSid = 'd5d43e96-7fca-4d9a-a589-cfa6220b99c6'

// resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
//   name: vnetName
//   scope: resourceGroup(vnetRgName)
// }

// resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
//   name: subnetName
//   parent: vnet
// }

module identity 'identity.bicep' = {
  name: 'identity-${shortTeamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    location: location
    environment: environment
    teamName: teamName
  }
}

// module keyvault '../_modules/keyvault/keyvault.bicep' = {
//   name: 'keyvault-${shortTeamName}-${environment}-${buildNumber}'
//   params: {
//     buildNumber: buildNumber
//     subnetId: subnet.id
//     location: location
//     environment: environment
//     teamName: shortTeamName
//     adminPrincipalIds: [admTeamSid]
//     userPrincipalIds: union([environmentConfig[environment].reqopsserviceId], identity.outputs.principalIds)
//   }
// }

// module database '../_modules/sql/sql.bicep' = {
//   name: 'database-${teamName}-${environment}-${buildNumber}'
//   params: {
//     buildNumber: buildNumber
//     subnetId: subnet.id
//     location: location
//     environment: environment
//     teamName: teamName
//     admGroupId: sqlAdmGroup
//     databases: [for database in sqlDatabases:  {
//       name: 'sqldb-${database.name}-${environment}-weu'
//       skuName: database.skuName
//     }]
//   }
// }

// module sqlAlerts '../_modules/sql/sql-alerts.bicep' = {
//   name: 'sqldbalerts-${teamName}-${environment}-${buildNumber}'
//   params:{
//     environment: environment
//     teamName: teamName
//     location: location
//   }
// }
