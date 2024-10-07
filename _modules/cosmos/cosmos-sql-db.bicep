@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Team resource name')
param teamName string

@description('CosmosAccount name for all resources.')
param cosmosAccountName string

param documentDBAccountContributors array = []
param containers array = []


resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = { 
  name: cosmosAccountName
}

var databaseName = 'db-${teamName}-${environment}-weu'
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  name: databaseName
  parent: cosmos
  location: location
  properties: {
    resource: { id: databaseName }
  }

  resource dbContainers 'containers' = [for container in containers: {
    name: container.name
    location: location
    properties: {
      resource: {
        id: container.id
        partitionKey: { paths: [ container.partitionKey ]}
      }
      options: {}
    }
  }]
}

module documentDBAccountContributor '../identity/roleAssignment.bicep' = {
  name: '${databaseName}-doc-acc-contr-${buildNumber}'
  params: {
    principalIds: documentDBAccountContributors
    roleName: 'DocumentDBAccountContributor'
  }
}
