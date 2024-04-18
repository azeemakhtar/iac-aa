param buildNumber string

param searchName string
param cosmosName string
param openAiName string
param keyVaultName string

resource search 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: searchName
}

module searchSecret '../_modules/keyvault/keyvault-secrets.bicep' = {
  name: '${search.name}-secret-${buildNumber}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'SearchKey'
    secretValue: search.listAdminKeys().primaryKey
  }
}

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: openAiName
}

module openAiSecret '../_modules/keyvault/keyvault-secrets.bicep' = {
  name: '${openAi.name}-secret-${buildNumber}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'OpenAiKey'
    secretValue: openAi.listKeys().key1
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosName
}

module cosmosSecret '../_modules/keyvault/keyvault-secrets.bicep' = {
  name: '${cosmos.name}-secret-${buildNumber}'
  params: {
    keyVaultName: keyVaultName
    secretName: 'CosmosDbAccountKey'
    secretValue: cosmos.listKeys().primaryMasterKey
  }
}
