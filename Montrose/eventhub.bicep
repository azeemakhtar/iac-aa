@description('Name of the EventHub Namespace')
param eventHubNamespaceName string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' existing = {
  name: eventHubNamespaceName
}

resource tradingphases 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'tradingphases'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 48
    }
    messageRetentionInDays: 1
    partitionCount: 32
    status: 'Active'
  }
}

resource orderdepths 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'orderdepths'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 48
    }
    messageRetentionInDays: 1
    partitionCount: 32
    status: 'Active'
  }
}

resource quotes 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'quotes'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 48
    }
    messageRetentionInDays: 1
    partitionCount: 32
    status: 'Active'
  }
}

resource trades 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'trades'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 48
    }
    messageRetentionInDays: 1
    partitionCount: 32
    status: 'Active'
  }
}

resource priceHistoryListener 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  name: 'price-history-listener'
  parent: trades
}

resource priceHistoryListener_quotes 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = {
  name: 'price-history-listener'
  parent: quotes
}


resource marketdataPushListener_orderdepths 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: orderdepths
  name: 'marketdata-push-listener'
  properties: {}
}

resource marketdataPushListener_quotes 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: quotes
  name: 'marketdata-push-listener'
  properties: {}
}

resource marketdataPushListener_trades 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: trades
  name: 'marketdata-push-listener'
  properties: {}
}

resource marketdataPushListener_tradingphases 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: tradingphases
  name: 'marketdata-push-listener'
  properties: {}
}


