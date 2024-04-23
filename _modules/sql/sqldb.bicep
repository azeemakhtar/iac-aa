param dbName string
param environment string
param location string
param skuName string
param sqlServerName string
param storageInBytes int

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: 'log-defaultlogging-${environment}-weu'
  scope: resourceGroup('rg-logs-${environment}-weu')
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

var standardDatabaseSizes = startsWith(skuName, 'Basic') ? 2147483648 : startsWith(skuName, 'S') ? 268435456000 : 536870912000 
var storage = storageInBytes > 0 ? storageInBytes :  standardDatabaseSizes

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: dbName
  location: location
  properties: {
    collation: 'Finnish_Swedish_CI_AS'
    requestedBackupStorageRedundancy: 'Zone'
    maxSizeBytes: storage
  }
  sku: {
    name: skuName
  }
}

resource sqlDBDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag${dbName}'
  scope: sqlDB
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
