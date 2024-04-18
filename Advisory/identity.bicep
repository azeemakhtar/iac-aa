@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string
module investmentOpportunity '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-investmentOpportunity-${environment}-${buildNumber}'
  params: {
    appName: 'investmentopportunity'
    k8sServiceAccountName: 'investment-opportunity'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module auditloggingservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-auditloggingservice-${environment}-${buildNumber}'
  params: {
    appName: 'auditloggingservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module advisorydbmigration '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-advisorydbmigration-${environment}-${buildNumber}'
  params: {
    appName: 'advisorydbmigration'
    k8sServiceAccountName: 'sql-migrator'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module featuretoggleservice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-featuretoggleservice-${environment}-${buildNumber}'
  params: {
    appName: 'featuretoggleservice'
    k8sServiceAccountName: 'feature-toggle'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module identityverification '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-identityverification-${environment}-${buildNumber}'
  params: {
    appName: 'identityverification'
    k8sServiceAccountName: 'identity-verificationservice'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module corporateaction '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-corporateaction-${environment}-${buildNumber}'
  params: {
    appName: 'corporateaction'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module promotedInstruments '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-promotedInstruments-${environment}-${buildNumber}'
  params: {
    appName: 'promotedInstruments'
    k8sServiceAccountName: 'promoted-instruments'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module panda '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-panda-${environment}-${buildNumber}'
  params: {
    appName: 'panda'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module clientInteractPlanner '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-clientinteractplanner-${environment}-${buildNumber}'
  params: {
    appName: 'clientinteractplanner'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}
module timingEventsGenerator '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-timingeventsgenerator-${environment}-${buildNumber}'
  params: {
    appName: 'timingeventsgenerator'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output advisorydbmigrationPrincipalId string = advisorydbmigration.outputs.principalId
output auditloggingservicePrincipalId string = auditloggingservice.outputs.principalId
output clientInteractPlannerPrincipalId string = clientInteractPlanner.outputs.principalId
output corporateactionPrincipalId string = corporateaction.outputs.principalId
output featuretoggleservicePrincipalId string = featuretoggleservice.outputs.principalId
output identityverificationPrincipalId string = identityverification.outputs.principalId
output investmentOpportunityPrincipalId string = investmentOpportunity.outputs.principalId
output pandaPrincipalId string = panda.outputs.principalId
output promotedInstrumentsPrincipalId string = promotedInstruments.outputs.principalId
output timingEventsGeneratorPrincipalId string = timingEventsGenerator.outputs.principalId

output advisoryIds array = [
  advisorydbmigration.outputs.principalId
  auditloggingservice.outputs.principalId
  clientInteractPlanner.outputs.principalId
  corporateaction.outputs.principalId
  featuretoggleservice.outputs.principalId
  identityverification.outputs.principalId
  investmentOpportunity.outputs.principalId
  panda.outputs.principalId
  promotedInstruments.outputs.principalId
  timingEventsGenerator.outputs.principalId
]
