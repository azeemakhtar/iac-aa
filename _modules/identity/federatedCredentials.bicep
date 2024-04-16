param tenantName string

param serviceAccountName string

@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

param managedIdentityName string

var environmentConfig = {
  dev: {
    oidcIssuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/1bf1d164-09b7-4ac5-bc93-2f7738ec42c0/'
  }
  test: {
    oidcIssuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/8f888136-dad7-472d-af79-2adfab324c51/'
  }
  preprod: {
    oidcIssuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/929cfc38-31b9-4918-bea2-6a08f37847ff/'
  }
  prod: {
    oidcIssuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/84d135ef-4c6e-452f-a377-d5aafb1b91eb/'
  }
}


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource federatedIdentityCredentials 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: 'k8s-${tenantName}-${environment}'
  parent: managedIdentity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: environmentConfig[environment].oidcIssuer
    subject: 'system:serviceaccount:${tenantName}-${environment}:${serviceAccountName}'
  }
}

output federatedCredentialsName string = federatedIdentityCredentials.name
