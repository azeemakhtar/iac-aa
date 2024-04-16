param location string = resourceGroup().location

@description('Teams nameto retrieve the action groups and for creating the alert')
param teamName string

@description('Name of the environment')
@allowed([
  'dev'
  'test'
  'preprod'
  'prod'
])
param environment string

resource teamAg 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  name: 'ag-${teamName}-${environment}'
  scope: resourceGroup()
}

resource teamCloudAg 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  name: 'ag-teamcloud-${environment}'
  scope: resourceGroup('rg-logs-${environment}-weu')
}

var actions = [
  {
    actionGroupId: teamAg.id
  }
  {
    actionGroupId: teamCloudAg.id
  }
]

resource CPUPercentage 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'sqldb-80CPUPercentage-${teamName}-${environment}'
  location: 'global'
  properties: {
    description: 'Whenever the average cpu percentage is greater than 80%'
    severity: 2
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: json('80.0')
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'cpu_percent'
          operator: 'greaterthan'
          timeAggregation: 'average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: actions
  }
}

resource LogIOPercentage 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'sqldb-80LogIOPercentage-${teamName}-${environment}'
  location: 'global'
  properties: {
    description: 'Whenever the average log io percentage is greater than 80%'
    severity: 2
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: json('80.0')
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'log_write_percent'
          operator: 'greaterthan'
          timeAggregation: 'average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: 'westeurope'
    actions: actions
  }
}

resource ProcentDTU 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'sqldb-80DTUPercentage-${teamName}-${environment}'
  location: 'global'
  properties: {
    description: 'Whenever the average DTU percentage is greater than 80%'
    severity: 2
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          threshold: json('80.0')
          name: 'Metric1'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          metricName: 'dtu_consumption_percent'
          operator: 'greaterthan'
          timeAggregation: 'average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: 'westeurope'
    actions: actions
  }
}
