param location string = 'South India'
param resourceGroupName string = 'sharedsrvrg'
param aksName string = 'demoaksy2201'
param acrName string = 'demoacry2201'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2023-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${aksName}-dns'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        vmSize: 'Standard_DS2_v2'
        count: 1
        osType: 'Linux'
        mode: 'System'
      }
    ]
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(aks.id, 'acrpull')
  scope: acr
  properties: {
    principalId: aks.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b9685316-3be3-493d-8fd3-2f8aa6942dbc')
  }
}
