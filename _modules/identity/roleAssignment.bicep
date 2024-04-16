param principalId string

param principalType string = 'ServicePrincipal'

@description('Name of the RBAC role to decode')
param roleName string

var roles = json(loadTextContent('../../base/roles.json'))
var roleGuid = roles[roleName]
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleGuid)
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
    principalType: principalType
  }
}
