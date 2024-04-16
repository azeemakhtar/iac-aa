
param location string = resourceGroup().location
param environment string
@allowed([ 'Free','Basic', 'Standard'])
param sku string

resource nftns 'Microsoft.NotificationHubs/namespaces@2017-04-01' = {
  name: 'nftns-montrose-${environment}-weu'
  location: location
  sku: {
    name: sku
  }
  properties: {
    namespaceType: 'NotificationHub'
  }
}

resource nftns_RootManageSharedAccessKey 'Microsoft.NotificationHubs/namespaces/AuthorizationRules@2017-04-01' = {
  parent: nftns
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

var nfsName = 'nfs-montrose-${environment}-weu'
resource nfs 'Microsoft.NotificationHubs/namespaces/notificationHubs@2017-04-01' = {
  parent: nftns
  name: nfsName
  location: location
  properties: {
    name: nfsName
    registrationTtl: '10675199.02:48:05.4775807'
  }
}

resource namespaces_nftns_montrose_weu_name_nfs_montrose_dev_weu_DefaultFullSharedAccessSignature 'Microsoft.NotificationHubs/namespaces/notificationHubs/AuthorizationRules@2017-04-01' = {
  parent: nfs
  name: 'DefaultFullSharedAccessSignature'
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

resource namespaces_nftns_montrose_weu_name_nfs_montrose_dev_weu_DefaultListenSharedAccessSignature 'Microsoft.NotificationHubs/namespaces/notificationHubs/AuthorizationRules@2017-04-01' = {
  parent: nfs
  name: 'DefaultListenSharedAccessSignature'
  properties: {
    rights: [
      'Listen'
    ]
  }
}




