param location string
param resourceName string
param subnetId string
param groupIds array
param resourceId string

var privateEndpointName = 'pe-${resourceName}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          groupIds: groupIds
          privateLinkServiceId: resourceId
        }
      }
    ]
  }
}

output privateEndpointName string = privateEndpoint.name
