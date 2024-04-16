param appName string

param environment string

param tenantName string

param buildNumber string

param location string = resourceGroup().location

param k8sServiceAccountName string = appName

module wi './managedIdentity.bicep' = {
  name: 'id-${tenantName}-${appName}-${environment}-${buildNumber}'
  params: {
    serviceAccountName: '${tenantName}-${appName}'
    environment: environment
    location: location
  }
}

module federatedCredentials './federatedCredentials.bicep' = {
  name: 'k8s-${tenantName}-${appName}-${environment}-${buildNumber}'
  params: {
    tenantName: tenantName
    environment: environment
    managedIdentityName: wi.outputs.managedIdentityName
    serviceAccountName: k8sServiceAccountName
  }
}

output principalId string = wi.outputs.managedIdentityPrincipalId
output name string = wi.outputs.managedIdentityName
