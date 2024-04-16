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

var teamName = 'clm'
var admTeamSid = '22faf833-1655-4d04-8da0-0c858429d350'

var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'

var environmentConfig = {
  dev: {
    groupExtensionServiceId: '4f68ad0b-3b3f-4b84-a541-0467b7e9eccd'
    selfServiceApiId: '2e8dc02c-0119-42b6-b3d9-c00fd51732f9'
    trapetsAdapterApiId: '082fe0f1-9185-4c6e-9c5b-825beb4e7e63'
    bisnodeAdapterApiId: '77bf7a3f-3e34-4a6c-bf92-4ba7244c1ffc'
    dependencyfinderDevId: 'c9d59291-4306-486d-8c1d-8c3dfeb0cf10'
    clientLifecycleService: '7f3babb4-49bc-44da-8c18-7d5114e3330c'
    clientportalService: '9ab3abd6-926d-444a-9c7c-b573bba462da'
    taskmanagementservice: '5de34753-bf08-4744-996e-4a47d370d7a1'
    
  }
  test: {
    groupExtensionServiceId: '04175dbb-b4d1-47ab-88c8-2aac9fac3d27'
    selfServiceApiId: 'ef308342-0082-40ae-ab06-2d112e27a540'
    trapetsAdapterApiId: '8bb5e53b-cba5-4829-8dda-a1c6a081da70'
    bisnodeAdapterApiId: '2a0c015c-4e80-40e2-9f6e-e549ace59800'
    dependencyfinderDevId: 'N/A'
    clientLifecycleService: 'd7ae3a37-eafc-49be-b492-17cdb1b599c3'
    clientportalService: 'b1b5388d-4256-460b-8723-c91fcd865e4c'
    taskmanagementservice: 'd6973b5b-6d24-480d-9a73-706cd7f39080'
  }
  preprod: {
    groupExtensionServiceId: '3a4b8783-2c5e-4769-839e-3cc2271ca2d0'
    selfServiceApiId: '8ae20ccb-c1e1-481d-9638-ad57a403b095'
    trapetsAdapterApiId: 'cc94fa15-a5d4-4b3e-8f4f-ed9f6a4f13d2'
    bisnodeAdapterApiId: '74bb1f87-2d3f-4fbf-aaa6-38c509575497'
    dependencyfinderDevId: 'N/A'
    clientLifecycleService: '68537537-eba2-4f74-af25-9fc9638e1e92'
    clientportalService: '901a02ee-c83e-4d0a-8ebf-633e6b218ed8'
    taskmanagementservice: '66e8eea6-7daf-4f81-9fe8-8893bee2d226'
  }
  prod: {
    groupExtensionServiceId: '008ba353-2d08-4df8-9a20-08bea7326334'
    selfServiceApiId: '10ff850d-d828-4527-abd1-f35b88878c1f'
    trapetsAdapterApiId: '86eb277d-800a-4b62-b158-f4b618ac0bd5'
    bisnodeAdapterApiId: 'ad9593d0-4c4b-4120-bb1f-89d73f2baed8'
    dependencyfinderDevId: 'N/A'
    clientLifecycleService: 'a273a076-b41a-440d-92be-c2e788952829'
    clientportalService: '9512266b-af80-4d87-ab2f-d16ee840fb76'
    taskmanagementservice: '6ec22ae6-8a2a-4f00-8747-802ee945ac6b'
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
    teamName: teamName
    buildNumber: buildNumber
  }
}

var kvAccessAppRegistrations = [
  identity.outputs.dependencyFinderPrincipalId
  environmentConfig[environment].dependencyfinderDevId // important to be the first 2
  environmentConfig[environment].groupExtensionServiceId
  environmentConfig[environment].selfServiceApiId
  environmentConfig[environment].trapetsAdapterApiId
  environmentConfig[environment].bisnodeAdapterApiId
  environmentConfig[environment].clientLifecycleService
  environmentConfig[environment].clientportalService
  environmentConfig[environment].taskmanagementservice
]
var kvAccessAppRegistrationsForEnvironment = environment == 'dev' ? kvAccessAppRegistrations : skip(kvAccessAppRegistrations, 2)
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
    userPrincipalIds: union(kvAccessAppRegistrationsForEnvironment, identity.outputs.clmIds)
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
