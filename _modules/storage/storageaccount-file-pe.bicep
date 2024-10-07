param stoName string
param stoId string
param location string = resourceGroup().location
param subnetId string
param environment string
param buildNumber string

module stoFilePrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${stoName}-file-privateendpoint-${buildNumber}'
  params: {
    resourceName: '${stoName}-file-${environment}-weu'
    location: location
    groupIds: [
      'file'
    ]
    resourceId: stoId
    subnetId: subnetId
  }
}

#disable-next-line no-hardcoded-env-urls
var sharePrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.file.core.windows.net')
module filePrivateDns '../network/privateDns.bicep' = {
  name: '${stoName}-privatedns-file-${buildNumber}'
  params: {
    privateDnsZoneId: sharePrivateDnsZoneId
    privateEndpointName: stoFilePrivateEndpoint.outputs.privateEndpointName
  }
}
