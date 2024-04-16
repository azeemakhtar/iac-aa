param sqlServerName string
param environment string
param dbName string
param location string
param skuName string

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'log-defaultlogging-${environment}-weu'
  scope: resourceGroup('rg-logs-${environment}-weu')
}
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: dbName
  location: location
  properties: {
    collation: 'Finnish_Swedish_CI_AS'
    requestedBackupStorageRedundancy: 'Zone'
    maxSizeBytes: startsWith(skuName, 'Basic') ?  2147483648 : 268435456000

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
