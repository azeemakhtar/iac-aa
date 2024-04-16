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

var teamName = 'client'

var vnetRgName = 'rg-vnet-${environment}-weu'
var vnetName = 'vnet-${environment}-weu'
var subnetName = 'snet-${teamName}-${environment}-weu'
// var admTeamName = 'az-grp-dep-Team Client-Admin'
var admTeamSid = '2fe6d607-8ef6-4814-ac95-e05e762e2e15'

var environmentConfig = {
  dev: {
    accountPerformanceId: 'b1b94052-6671-446b-8765-8ecdcc6e7766'
    instrumentMonitoring: '5d93e38f-3079-427f-b56c-47465dcd722f'
    curityAuthenicationAdapter: '395a7239-f42c-4779-8f64-2f02f8171bab'
    manageradmin: 'e9c9b194-1052-4143-93d0-015591b32051'
    pbOnlineId: 'e6e5e71c-c09f-4009-94c4-b03987c4c9ed'
  }
  test: {
    accountPerformanceId: '84978e79-dc25-4447-b32d-61e369eae50d'
    instrumentMonitoring: '07ba1314-dbd7-4ee6-b815-e544a562a277'
    curityAuthenicationAdapter: '8d6ba117-3e11-4b74-b223-987d5912e892'
    manageradmin: '31447d80-44e3-4633-a920-6530687d4ee4'
    pbOnlineId: '42f8a91b-654c-4d0d-b441-0c77458eed95'

  }
  preprod: {
    accountPerformanceId: '9d16c7ae-0966-414c-bb28-92e9fb815d76'
    instrumentMonitoring: 'e00fa648-b840-4840-95e9-d1abe8d880ff'
    curityAuthenicationAdapter: 'f64de672-937c-4eab-85e9-9d83402f5bbe'
    manageradmin: '42797b87-4840-4229-a6bb-28e12fa72ac9'
    pbOnlineId: '3e45f648-b077-4654-8232-8f6392c5a7e0'
  }
  prod: {
    accountPerformanceId: 'a3946f8c-350d-426c-8b33-2fd9c991bc1d'
    instrumentMonitoring: 'e2b4e719-00bb-4670-811b-506576eaf391'
    curityAuthenicationAdapter: 'a6eff108-208f-4674-830b-47830ae787f6'
    manageradmin: '7977a82e-9bc7-4a5a-af44-4cc808dd0a67'
    pbOnlineId: '9d689e34-0039-475c-ae1d-b83d4bc7f9e0'
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
    environment: environment
    location: location
    buildNumber: buildNumber
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
        environmentConfig[environment].accountPerformanceId
        environmentConfig[environment].instrumentMonitoring
        environmentConfig[environment].curityAuthenicationAdapter
        environmentConfig[environment].manageradmin
        environmentConfig[environment].pbOnlineId
      ], identity.outputs.principalIds)
    signingPrincipalIds: [
      environmentConfig[environment].curityAuthenicationAdapter
      identity.outputs.curityAuthenticationAdapterPrincipalId
    ]
    }

}

module storage 'storageaccount.bicep' = {
  name: 'st-${teamName}-${environment}-${buildNumber}'
  params: {
    environment: environment
    location: location
    name: 'mediafiles'
  }
}
