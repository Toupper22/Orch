// RBAC Role Assignment Module
// Assigns Azure RBAC roles to principals (users, groups, service principals, managed identities)

@description('The principal ID (object ID) to assign the role to')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

@description('The type of principal')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
  'ForeignGroup'
])
param principalType string = 'ServicePrincipal'

@description('Description of the role assignment')
param roleDescription string = ''

// Create the role assignment with a deterministic GUID
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
    description: !empty(roleDescription) ? roleDescription : null
  }
}

// Outputs
@description('Role assignment ID')
output id string = roleAssignment.id

@description('Role assignment name')
output name string = roleAssignment.name
