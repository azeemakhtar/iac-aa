param stoName string
param stoId string
param location string = resourceGroup().location
param subnetId string
param environment string
param buildNumber string

module stoBlobPrivateEndpoint '../network/privateendpoint.bicep' = {
  name: '${stoName}-blob-privateendpoint-${buildNumber}'
  params: {
    resourceName: '${stoName}-blob-${environment}-weu'
    location: location
    groupIds: [
      'blob'
    ]
    resourceId: stoId
    subnetId: subnetId
  }
}

#disable-next-line no-hardcoded-env-urls
var blobPrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.windows.net')
module blobPrivateDns '../network/privateDns.bicep' = {
  name: '${stoName}-privatedns-blob-${buildNumber}'
  params: {
    privateDnsZoneId: blobPrivateDnsZoneId
    privateEndpointName: stoBlobPrivateEndpoint.outputs.privateEndpointName
  }
}
