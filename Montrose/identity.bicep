@description('Name of the environment')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Build number to use for tagging deployments')
param buildNumber string

param teamName string

module newsService '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-news-service-${environment}-${buildNumber}'
  params: {
    appName: 'news-service'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module marketdata '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-marketdata-${environment}-${buildNumber}'
  params: {
    appName: 'marketdata'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module marketdataFeeder '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-marketfeeder-${environment}-${buildNumber}'
  params: {
    appName: 'marketdata-feeder'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module priceHistory '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-priceHistory-${environment}-${buildNumber}'
  params: {
    appName: 'price-history'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module testpersons '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-test-persons-${environment}-${buildNumber}'
  params: {
    appName: 'test-persons'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module montrosedbmigrator '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-db-migrator-${environment}-${buildNumber}'
  params: {
    appName: 'db-migrator'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-db-migrator'
  }
}

module montroseCrmapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-crmapi-${environment}-${buildNumber}'
  params: {
    appName: 'crmapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-crmapi'
  }
}

module montroseApigateway '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-apigateway-${environment}-${buildNumber}'
  params: {
    appName: 'apigateway'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-apigateway'
  }
}

module montrosePayments '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-payments-${environment}-${buildNumber}'
  params: {
    appName: 'payments'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-payments'
  }
}

module montrosePaymentsCallback '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-payments-callback-${environment}-${buildNumber}'
  params: {
    appName: 'payments-callback'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-payments-callback'
  }
}

module montroseOnboarding '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-onboarding-${environment}-${buildNumber}'
  params: {
    appName: 'onboarding'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-onboarding'
  }
}

module montroseHoldings '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-holdings-${environment}-${buildNumber}'
  params: {
    appName: 'holdings'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-holdings'
  }
}

module montrosePrice '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-price-${environment}-${buildNumber}'
  params: {
    appName: 'price'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-price'
  }
}

module montrosePortfolio '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-portfolio-${environment}-${buildNumber}'
  params: {
    appName: 'portfolio'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-portfolio'
  }
}

module depositnotificationapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-depositnotificationapi-${environment}-${buildNumber}'
  params: {
    appName: 'depositnotificationapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-depositnotificationapi'
  }
}

module montroseWebapi '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-webapi-${environment}-${buildNumber}'
  params: {
    appName: 'webapi'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
    k8sServiceAccountName: 'montrose-webapi'
  }
}

module companyfacts '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-companyfacts-${environment}-${buildNumber}'
  params: {
    appName: 'companyfacts'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module factsetLoader '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-factsetLoader-${environment}-${buildNumber}'
  params: {
    appName: 'factset-loader'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

module treasuryTrustly '../_modules/identity/workloadidentity.bicep' = {
  name: 'wid-${teamName}-treasuryTrustly-${environment}-${buildNumber}'
  params: {
    appName: 'treasury-trustly'
    environment: environment
    location: location
    buildNumber: buildNumber
    tenantName: teamName
  }
}

output testPersonsPrincipalId string = testpersons.outputs.principalId
output dbMigratorPrincipalId string = montrosedbmigrator.outputs.principalId
output crmapiPrincipalId string = montroseCrmapi.outputs.principalId
output apigatewayPrincipalId string = montroseApigateway.outputs.principalId
output paymentsPrincipalId string = montrosePayments.outputs.principalId
output paymentsCallbackPrincipalId string = montrosePaymentsCallback.outputs.principalId
output onboardingPrincipalId string = montroseOnboarding.outputs.principalId
output holdingsPrincipalId string = montroseHoldings.outputs.principalId
output pricePrincipalId string = montrosePrice.outputs.principalId
output portfolioPrincipalId string = montrosePortfolio.outputs.principalId
output depositnotificationapiPrincipalId string = depositnotificationapi.outputs.principalId
output webapiPrincipalId string = montroseWebapi.outputs.principalId
output newsServicePrincipalId string = newsService.outputs.principalId
output marketdataFeederId string = marketdataFeeder.outputs.principalId
output marketdataId string = marketdata.outputs.principalId
output priceHistoryId string = priceHistory.outputs.principalId
output companyfactsPrincipalId string = companyfacts.outputs.principalId
output factsLoaderPrincipalId string = factsetLoader.outputs.principalId
output treasuryTrustlyPrincipalId string = treasuryTrustly.outputs.principalId

output montroseIds array = [
  testpersons.outputs.principalId
  montrosedbmigrator.outputs.principalId
  montroseCrmapi.outputs.principalId
  montroseApigateway.outputs.principalId
  montrosePayments.outputs.principalId
  montrosePaymentsCallback.outputs.principalId
  montroseOnboarding.outputs.principalId
  montroseHoldings.outputs.principalId
  montrosePrice.outputs.principalId
  montrosePortfolio.outputs.principalId
  depositnotificationapi.outputs.principalId
  montroseWebapi.outputs.principalId
  newsService.outputs.principalId
  marketdataFeeder.outputs.principalId
  marketdata.outputs.principalId
  priceHistory.outputs.principalId
  companyfacts.outputs.principalId
  factsetLoader.outputs.principalId
  treasuryTrustly.outputs.principalId
]
