@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Team resource name')
param teamName string

@description('Resource id for the subnet to use for private endpoints')
param subnetId string

param documentDBAccountContributors array = []

module cosmos '../_modules/cosmos/cosmos-account.bicep' = {
  name: 'cosmos-${teamName}-${environment}-${buildNumber}'
  params: {
    kind: 'GlobalDocumentDB'
    location: location
    environment: environment
    teamName: teamName
    buildNumber: buildNumber
    subnetId: subnetId
  }
}

module database '../_modules/cosmos/cosmos-sql-db.bicep' = {
  name: 'db-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    cosmosAccountName: cosmos.outputs.cosmosName
    environment: environment
    teamName: teamName
    containers: [
      {
          name: 'conversations'
          partitionKey: '/userId'
          id: 'conversations'
      }
    ]
    documentDBAccountContributors: documentDBAccountContributors
    location: location
  }
}

output cosmosName string = cosmos.outputs.cosmosName
