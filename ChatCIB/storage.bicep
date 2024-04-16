@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Team resource name')
param teamName string

param storageBlobDataContributors array = []

module storage '../_modules/storage/storageaccount.bicep' = {
  name: 'storage-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'chatcib'
    subnetId: subnetId
    buildNumber: buildNumber
    usedAsFileShare: false
    usedAsBlob: true
  }
}

module queueBlob '../_modules/storage/blob.bicep' = {
  name: 'queueBlob-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'queue'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

module analyzedBlob '../_modules/storage/blob.bicep' = {
  name: 'analyzedBlob-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'analyzed'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

module archivedBlob '../_modules/storage/blob.bicep' = {
  name: 'archivedBlob-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'archived'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

module indexedBlob '../_modules/storage/blob.bicep' = {
  name: 'indexedBlob-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'indexed'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}
