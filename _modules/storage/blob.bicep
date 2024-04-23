@description('Name of the blob.')
param blobName string

@description('StorageAccount name for all resources.')
param stoAccountName string

param buildNumber string

param storageBlobDataContributors array = []

resource stg 'Microsoft.Storage/storageAccounts@2019-04-01' existing = {
  name: stoAccountName
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: stg
  properties: {
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 30
      enabled: true
    }
    isVersioningEnabled: false
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 30
      enabled: true
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: blobName
  parent: blobServices
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    metadata: {}
    publicAccess: 'None'
  }
}

module storageBlobDataContributor '../identity/roleAssignment.bicep' = {
  name: '${blobName}-blobcontributor-${buildNumber}'
  params: {
    roleName: 'StorageBlobDataContributor'
    principalIds: storageBlobDataContributors
  }
}
