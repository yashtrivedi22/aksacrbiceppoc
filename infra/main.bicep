@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Azure Container Registry')
param acrName string = 'acryt2201demo'

@description('Name of the AKS Cluster')
param aksName string = 'aksyt2201demo'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.29.0'

@description('Node pool VM size')
param agentVMSize string = 'Standard_DS2_v2'

@description('Node count')
param agentCount int = 2

// -------------------------
// Deploy ACR
// -------------------------

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
}

// -------------------------
// Deploy AKS
// -------------------------

resource aks 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: aksName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${aksName}-dns'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: agentCount
        vmSize: agentVMSize
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
    }
  }
}

// -------------------------
// Managed Identity for AKS
// -------------------------

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${aksName}-identity'
  location: location
}

// -------------------------
// Role Assignment: AcrPull
// -------------------------

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managedIdentity.id, acr.id, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'  // AcrPull role
    )
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// -------------------------
// Outputs
// -------------------------

output acrLoginServer string = acr.properties.loginServer
output aksName string = aks.name
output managedIdentityClientId string = managedIdentity.properties.clientId
