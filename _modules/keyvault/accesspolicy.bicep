param identityObjectIds array
param vaultName string
param tenantId string = subscription().tenantId
param permissions object

resource keyvaultaccesspolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${vaultName}/add'
  properties: {
    accessPolicies: [for id in identityObjectIds : {
        objectId: id
        tenantId: tenantId
        permissions: permissions
      }]
  }
}
