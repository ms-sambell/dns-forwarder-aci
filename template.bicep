param containerAppName string = 'aci-dns'
param storageAccountName string 
param storageAccountResourceGroup string
param azureFileShareName string 
param containerImage string = 'ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder'
param vnetName string
param subnetName string
param vnetResourceGroupName string
  

resource storageAcc 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
  scope: resourceGroup(storageAccountResourceGroup)
}

resource containerGroups_aci_dns_name_resource 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: containerAppName
  location: resourceGroup().location
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: containerAppName
        properties: {
          image: containerImage
          ports: [
            {
              protocol: 'UDP'
              port: 53
            }
          ]
          volumeMounts: [
            {
              name: 'azurefile'
              mountPath: '/etc/bind'
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: '1.5'
              cpu: 1
            }
          }
        }
      }
    ]
    initContainers: []
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          protocol: 'UDP'
          port: 53
        }
      ]
      type: 'Private'
    }
    osType: 'Linux'
    volumes: [
      {
        name: 'azurefile'
        azureFile: {
          shareName: azureFileShareName
          storageAccountName: storageAcc.name
          storageAccountKey: storageAcc.listKeys().keys[0].value
        }
      }
    ]
    subnetIds: [
      {
        id:  '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'
      }
    ]
  }
}
