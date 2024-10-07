param privateEndpointName string
param privateDnsZoneConfigs array

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: '${privateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: privateDnsZoneConfigs
  }
}
