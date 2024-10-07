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

param ipRules array = []

param firewallRules array = []

var teamName = 'dbbi'

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

module storage 'storageaccount.bicep' = {
  name: 'st-auditbi-${environment}-${buildNumber}'
  params: {
    environment: environment
    location: location
    name: 'media'
    ipRules: ipRules
  }
}

module database 'sql.bicep' = {
  name: 'sql-auditbi-${buildNumber}'
  params: {
    admGroupId: '71101181-618d-4bfa-a111-f3500c595096'
    buildNumber: buildNumber
    environment: environment
    teamName: teamName
    location: location
    firewallRules: firewallRules
    subnetId: subnet.id
  }
}
