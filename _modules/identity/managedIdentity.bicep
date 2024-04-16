param serviceAccountName string

@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${serviceAccountName}-${environment}-weu'
  location: location
}

output managedIdentityName string = managedIdentity.name
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityCLientId string = managedIdentity.properties.clientId

