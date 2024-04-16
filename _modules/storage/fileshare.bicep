@description('Name of the file share.')
param shareName string

@description('StorageAccount name for all resources.')
param stoAccountName string 

resource stg 'Microsoft.Storage/storageAccounts@2019-04-01' existing = {
  name: stoAccountName
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: stg
  properties: {
    shareDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 7
      enabled: true
    }
  }
}

resource symbolicname 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name:  shareName
  parent: fileServices
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols: 'smb'
    shareQuota: 5
  }
}

