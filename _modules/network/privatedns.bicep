param privateEndpointName string
param privateDnsZoneId string

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: '${privateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateEndpointName
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
