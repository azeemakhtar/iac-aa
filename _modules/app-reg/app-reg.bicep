param location string = resourceGroup().location
param appName string
@secure()
param clientId string
@secure()
param clientSecret string
@secure()
param tenantId string

var environmentConfig = {
  dev: {
    issuer: 'https://oidc.prod-aks.azure.com/6b15e794-50ed-4481-8146-fa7703e72687/'
  }
  test: {
    issuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/74840e8e-0018-42bc-a959-c58de2ad2710/'
  }
  preprod: {
    issuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/a99cd0b4-5e14-4ec9-ae14-a39d8d07e4c9/'
  }
  prod: {
    issuer: 'https://westeurope.oic.prod-aks.azure.com/904e2f8f-5832-43bf-aea8-7cbfde1c5d4c/95d96c2f-aa96-4e68-9ef0-28317efb6f74/'
  }
}



resource appReg 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'appreg-get'
  location: location
  kind: 'AzureCLI'
  properties: {
    arguments: '-AppName ${appName}'
    // azPowerShellVersion: '8.3'
    azCliVersion: '2.4.0'
    retentionInterval: 'P1D'
    scriptContent: loadTextContent('./app-reg.sh')
  
    environmentVariables: [
      {
        name: 'clientId'
        value: clientId
      }
      {
        name: 'tenantId'
        value: tenantId
      }
      {
        name: 'clientSecret'
        value: clientSecret
      }
    ]
  }
}
output objectId string = 'hejhop' // appReg.properties.outputs.objectId
output appId string = 'hejhop' // appReg.properties.outputs.appId
