@description('Team name for resources')
param teamName string

@description('Location for all resources')
param location string

@description('Environment Name')
@allowed([ 'dev', 'test', 'preprod','prod' ])
param environment string

@description('Daily data volume cap in GB')
param dailyCap int = 2

@description('Log retention period in days')
param logRetention int = 90

var appInsightsName = 'appi-${teamName}-${environment}-weu'
var logAnalyticsRgName = 'rg-logs-${environment}-weu'
var logAnalyticsName = 'log-defaultlogging-${environment}-weu'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsName
  scope: resourceGroup(logAnalyticsRgName)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    RetentionInDays: logRetention
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource appInsightsPricingPlan 'Microsoft.Insights/components/pricingPlans@2017-10-01' = {
  parent: appInsights
  name: 'current'
  properties: {
    planType: 'Basic'
    cap: dailyCap
    warningThreshold: 70
    stopSendNotificationWhenHitCap: false
    stopSendNotificationWhenHitThreshold: false
  }
}

resource appInsightsQueryPack 'Microsoft.OperationalInsights/queryPacks@2019-09-01' = {
  name: 'pack-${teamName}-${environment}-weu'
  location: location
  properties: {}
}

output appInsightsId string = resourceId('Microsoft.Insights/components', appInsightsName)
