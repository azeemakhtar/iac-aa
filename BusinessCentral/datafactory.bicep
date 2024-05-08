@description('Build number to use for tagging deployments')
param buildNumber string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the environment')
@allowed([ 'dev','test', 'preprod', 'prod'])
param environment string

@description('Team resource name')
param teamName string

param dataFactoryName string = 'adf-${teamName}-${environment}-weu'


@description('Subnet id')
param subnetId string


// @description('Name of the Azure storage account that contains the input/output data.')
// param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

// @description('Name of the blob container in the Azure Storage account.')
// param blobContainerName string = 'blob${uniqueString(resourceGroup().id)}'

// var dataFactoryLinkedServiceName = 'ArmtemplateStorageLinkedService'
// var dataFactoryDataSetInName = 'ArmtemplateTestDatasetIn'
// var dataFactoryDataSetOutName = 'ArmtemplateTestDatasetOut'
// var pipelineName = 'ArmtemplateSampleCopyPipeline'

// // resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//   name: storageAccountName
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'

//   properties: {
//     minimumTlsVersion: 'TLS1_2'
//     supportsHttpsTrafficOnly: true
//     allowBlobPublicAccess: false
//   }

//   resource defaultBlobService 'blobServices' = {
//     name: 'default'
//   }
// }

// resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
//   parent: storageAccount::defaultBlobService
//   name: blobContainerName
// }

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    publicNetworkAccess: 'Disabled'

  
  }
}

module adfPrivateEndpoint '../_modules/network/privateendpoint.bicep' = {
  name: '${dataFactoryName}-pe-${buildNumber}'
  params: {
    resourceName: dataFactory.name
    location: location
    groupIds: [
      'dataFactory'
    ]
    resourceId: dataFactory.id
    subnetId: subnetId
  }
}

var privateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.datafactory.azure.net')
module adfPrivateDns '../_modules/network/privateDns.bicep' = {
  name: '${dataFactoryName}-adfdns-${buildNumber}'
  params: {
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: adfPrivateEndpoint.outputs.privateEndpointName
  }
}


// var portalPrivateDnsZoneId = resourceId('ac5f16ed-4024-4b4c-ae78-0992d01c1f34', 'rg-privatednszones-shared-weu', 'Microsoft.Network/privateDnsZones', 'privatelink.adf.azure.com')
// module adfPortalPrivateDns '../_modules/network/privateDns.bicep' = {
//   name: '${dataFactoryName}-adfportaldns-${buildNumber}'
//   params: {
//     privateDnsZoneId: portalPrivateDnsZoneId
//     privateEndpointName: adfPrivateEndpoint.outputs.privateEndpointName
//   }
// }

// resource dataFactoryLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
//   parent: dataFactory
//   name: dataFactoryLinkedServiceName
//   properties: {
//     type: 'AzureBlobStorage'
//     typeProperties: {
//       connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
//     }
//   }
// }

// resource dataFactoryDataSetIn 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
//   parent: dataFactory
//   name: dataFactoryDataSetInName
//   properties: {
//     linkedServiceName: {
//       referenceName: dataFactoryLinkedService.name
//       type: 'LinkedServiceReference'
//     }
//     type: 'Binary'
//     typeProperties: {
//       location: {
//         type: 'AzureBlobStorageLocation'
//         container: blobContainerName
//         folderPath: 'input'
//         fileName: 'emp.txt'
//       }
//     }
//   }
// }

// resource dataFactoryDataSetOut 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
//   parent: dataFactory
//   name: dataFactoryDataSetOutName
//   properties: {
//     linkedServiceName: {
//       referenceName: dataFactoryLinkedService.name
//       type: 'LinkedServiceReference'
//     }
//     type: 'Binary'
//     typeProperties: {
//       location: {
//         type: 'AzureBlobStorageLocation'
//         container: blobContainerName
//         folderPath: 'output'
//       }
//     }
//   }
// }

// resource dataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
//   parent: dataFactory
//   name: pipelineName
//   properties: {
//     activities: [
//       {
//         name: 'MyCopyActivity'
//         type: 'Copy'
//         typeProperties: {
//           source: {
//             type: 'BinarySource'
//             storeSettings: {
//               type: 'AzureBlobStorageReadSettings'
//               recursive: true
//             }
//           }
//           sink: {
//             type: 'BinarySink'
//             storeSettings: {
//               type: 'AzureBlobStorageWriteSettings'
//             }
//           }
//           enableStaging: false
//         }
//         inputs: [
//           {
//             referenceName: dataFactoryDataSetIn.name
//             type: 'DatasetReference'
//           }
//         ]
//         outputs: [
//           {
//             referenceName: dataFactoryDataSetOut.name
//             type: 'DatasetReference'
//           }
//         ]
//       }
//     ]
//   }
// }

// output name string = dataFactoryPipeline.name
// output resourceId string = dataFactoryPipeline.id
output resourceGroupName string = resourceGroup().name
output location string = location
