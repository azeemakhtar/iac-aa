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

@description('Team resource name')
param teamName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@description('Object id for the regular user access AAD group')
param userPrincipalIds array = []

@description('Object id for the admin access AAD group')
param adminPrincipalIds array

param signingPrincipalIds array = []


@description('Set to true if the vault already exists (avoids owerwriting accesspolicies')
param vaultExists bool = false

var keyVaultName = 'kv-${teamName}-${environment}-weu'


// var keyvaultContribuitorRole = 'f25e0fa2-a7c8-4377-a976-54943a77a395'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'log-defaultlogging-${environment}-weu'
  scope: resourceGroup('rg-logs-${environment}-weu')
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    createMode: vaultExists ? 'recover' : 'default'
    accessPolicies: []
    enableRbacAuthorization: false
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
  }
}

resource kvDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag${keyVaultName}'
  scope: keyVault
  properties: {
    workspaceId: logWorkspace.id
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
  }
}


module keyVaultPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${keyVaultName}-privateendpoint-${buildNumber}'
  params: {
    resourceName: keyVaultName
    location: location
    groupIds: [
      'vault'
    ]
    resourceId: keyVault.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')
module keyVaultPrivateDns '../network/privateDns.bicep' = {
  name: '${keyVaultName}-privatedns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: keyVaultPrivateEndpoint.outputs.privateEndpointName
  }
}
 
module userPermissions './accesspolicy.bicep' = {
  name: 'kv-ua-${buildNumber}'
  params: {
    identityObjectIds: userPrincipalIds
    vaultName: keyVault.name
    permissions: {
      secrets: [
        'get'
        'list'
      ]
      keys: [
        'get'
        'list'
      ]
      certificates: [
        'get'
        'list'
      ]
    }
  }
}

module adminPermissions './accesspolicy.bicep'  = {
  name: 'kv-aa-${buildNumber}'
  params: {
    identityObjectIds: adminPrincipalIds
    vaultName: keyVault.name
    permissions: {
      secrets: [
        'all'
      ]
      keys: [
        'all'
      ]
      certificates: [
        'all'
      ]
    }
  }
  dependsOn: [
    userPermissions
  ]
}

module signingPermissions './accesspolicy.bicep' = if (!empty(signingPrincipalIds)) {
  name: 'kv-sig-${buildNumber}'
  params: {
    identityObjectIds: signingPrincipalIds
    vaultName: keyVault.name
    permissions: {
      keys: [
        'get'
        'list'
        'sign'
      ]
    }
  }
  dependsOn: [
    adminPermissions
  ]
}
output keyValutName string =  keyVault.name
