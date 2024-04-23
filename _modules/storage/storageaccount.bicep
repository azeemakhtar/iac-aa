@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the storage account.')
param name string

@description('The team sid to assign the blob data reader role.')
param teamSid string = ''

@description('Build number that deploys the infrastructure')
param buildNumber string

param subnetId string

@description('Deploy private endpoint for file')
param usedAsFileShare bool = false

@description('Deploy private endpoint for blob')
param usedAsBlob bool = true



resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  name: 'st${name}${environment}weu'
  location: location
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

module blobPe 'storageaccount-blob-pe.bicep' = if (usedAsBlob) {
  name: '${storageAccount.name}-blob-pe-${buildNumber}'
  params: {
    stoName: storageAccount.name
    location: storageAccount.location
    subnetId: subnetId
    buildNumber: buildNumber
    environment: environment
    stoId: storageAccount.id
  }
}

module filePe 'storageaccount-file-pe.bicep' = if (usedAsFileShare) {
  name: '${storageAccount.name}-file-pe-${buildNumber}'
  params: {
    stoName: storageAccount.name
    location: storageAccount.location
    subnetId: subnetId
    buildNumber: buildNumber
    environment: environment
    stoId: storageAccount.id
  }
}

module storagedatareader '../identity/roleAssignment.bicep' = if (teamSid != ''){
  name: '${teamSid}-blobdatareader-${buildNumber}'
  params: {
    principalIds: [teamSid]
    roleName: 'StorageBlobDataReader'
    principalType: 'Group'
  }
}

output stoName string = storageAccount.name
