@description('Name of the environment')
@allowed(['dev', 'test' , 'preprod', 'prod'])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param tenantName string

module chatcibjobIdentity '../_modules/identity/managedIdentity.bicep' = {
  name: 'id-${tenantName}-job-${environment}-${buildNumber}'
  params: {
    serviceAccountName: '${tenantName}-job'
    environment: environment
    location: location
  }
}

module chatcibjobFederatedCredentials '../_modules/identity/federatedCredentials.bicep' = {
  name: 'k8s-${tenantName}-job-${environment}-${buildNumber}'
  params: {
    tenantName: tenantName
    environment: environment
    managedIdentityName: chatcibjobIdentity.outputs.managedIdentityName
    serviceAccountName: '${tenantName}-job'
  }
}

module chatcibwebIdentity '../_modules/identity/managedIdentity.bicep' = {
  name: 'id-${tenantName}-web-${environment}-${buildNumber}'
  params: {
    serviceAccountName: '${tenantName}-web'
    environment: environment
    location: location
  }
}

module chatcibwebFederatedCredentials '../_modules/identity/federatedCredentials.bicep' = {
  name: 'k8s-${tenantName}-web-${environment}-${buildNumber}'
  params: {
    tenantName: tenantName
    environment: environment
    managedIdentityName: chatcibwebIdentity.outputs.managedIdentityName
    serviceAccountName: '${tenantName}-web'
  }
}

output chatcibjobPrincipalId string = chatcibjobIdentity.outputs.managedIdentityPrincipalId
output chatcibwebPrincipalId string = chatcibwebIdentity.outputs.managedIdentityPrincipalId
