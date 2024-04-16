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
  name: 'sto-${teamName}-${environment}-${buildNumber}'
  params: {
    location: location
    environment: environment
    name: 'checkpoints'
    buildNumber: buildNumber
    subnetId: subnetId
    usedAsFileShare: false
    usedAsBlob: true
  }
}

module marketDataBlob '../_modules/storage/blob.bicep' = {
  name: 'marketdata-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'marketdata-checkpoints'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

module priceHistoryBlob '../_modules/storage/blob.bicep' = {
  name: 'price-history-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'price-history-trades-checkpoints'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

module priceHistoryQuotesBlob '../_modules/storage/blob.bicep' = {
  name: 'quotes-${teamName}-${environment}-${buildNumber}'
  params: {
    blobName: 'price-history-quotes-checkpoints'
    stoAccountName: storage.outputs.stoName
    buildNumber: buildNumber
    storageBlobDataContributors: storageBlobDataContributors
  }
}

