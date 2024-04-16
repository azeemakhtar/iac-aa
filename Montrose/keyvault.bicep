@description('Build number to use for tagging deployments')
param buildNumber string

@description('Name of the environment')
@allowed([
  'dev'
  'test'
  'preprod'
  'prod'
])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location
param teamName string
param admTeamSid string
param subnetId string
param userPrincipalIds array = []

var environmentConfig = {
  dev: {
    apigatewayId: '6993b434-0759-4892-b552-d0c8e38e6c70'
    crmapiId: '469aa69f-4dc3-47ce-879c-04c231d410e7'
    depositnotificationapiId: 'f533a0a5-4578-4cc2-bf90-4acc6ae42caf'
    holdingsId: '6b3bb476-3f62-400f-8fef-36058f6a7819'
    montrosedbmigratorId: '127a1f37-d4c3-48ce-9721-cef177d1e519'
    onboardingId: 'a6fe46a5-3b5f-4c22-8150-196678ed0261'
    paymentsCallbackId: '8d774f1b-4d57-423a-9692-a1407608240b'
    paymentsId: 'f0c5f704-edd9-4a26-80ad-b5659e01173d'
    priceId: 'dce4cbdc-ce9c-465a-81dc-e52825d582a8'
    webapiId: '7f209f61-0709-496a-943b-35e476400a6e'
  }

  test: {
    apigatewayId: '62cb54c1-0d47-4d5d-ae6d-4a81cec08518'
    crmapiId: 'cd2ca981-456b-407d-b8d8-75d98f1738c4'
    depositnotificationapiId: '01cb9cac-682c-4943-be8d-30a97488d9fc'
    holdingsId: '380ccb6f-ec43-48d1-a142-3e410a7c4471'
    montrosedbmigratorId: 'fd3c5e44-c3cb-46f6-87fd-ed05ceb7edcb'
    onboardingId: '544b1b5b-44fe-4362-b252-0f4631db5e3d'
    paymentsCallbackId: '15440a47-d26c-41d6-aca8-6eaa868270a0'
    paymentsId: 'b32f5b25-a428-4ffa-84c9-afe1ff6f0c6c'
    priceId: 'cccd4d24-6200-4f84-9918-46ad3ac47977'
    webapiId: '04156353-c40d-42b5-af54-b516d0419a6b'
  }

  preprod: {
    apigatewayId: 'c8e84ecb-72f0-4fb8-b93d-1a2483c5299c'
    crmapiId: '350df837-a3ea-49a2-adb6-9933b9367c81'
    depositnotificationapiId: '433b56d7-d2d3-4cf5-b71e-31a7f2fa8dfd'
    holdingsId: '0a74ff5a-8d7d-48a5-a0c4-41e06d49cfc0'
    montrosedbmigratorId: '0dab9791-e3ac-48eb-9d26-e838556a4d2c'
    onboardingId: 'b295436d-76a4-4a5f-926e-2284be68d824'
    paymentsCallbackId: '8e89a251-64c6-43ca-817d-473df66cbdc8'
    paymentsId: '0a23b043-de33-46a5-8aa4-8484b26c8188'
    priceId: '9515725b-eb19-415f-ad96-231e7abe54b7'
    webapiId: '037a68be-bb56-4542-a07d-387ba0d027c4'
  }
  prod: {
    apigatewayId: '08a5e6d8-d3fb-43f8-bd46-6155b556b64b'
    crmapiId: 'bf0f835b-6fd0-4b27-87bd-f08dae698d7b'
    depositnotificationapiId: '0b17defd-05da-4aea-9990-64da48f0d4f1'
    holdingsId: '7386bbf1-5f4e-4534-b219-985c75eacc4d'
    montrosedbmigratorId: '415dc2cb-4754-47dd-bbc2-30c7ffe51836'
    onboardingId: 'c81f8ccb-1ffa-428d-8041-142b4c854209'
    paymentsCallbackId: '7ca2a106-e9fe-4ce8-a5d0-7611ccb8ce40'
    paymentsId: '2ba53839-7ceb-4380-a4a3-937becc8db96'
    priceId: 'f93701e5-8d6d-4ed2-8033-c93222c91c44'
    webapiId: '5760c907-d4d5-4899-afd3-c013c655e674'
  }
}

var kvAccessAppRegistrations = [
  environmentConfig[environment].depositnotificationapiId
  environmentConfig[environment].apigatewayId
]

module keyvault '../_modules/keyvault/keyvault.bicep' = {
  name: 'kv-${teamName}-${environment}-${buildNumber}'
  params: {
    buildNumber: buildNumber
    subnetId: subnetId
    location: location
    environment: environment
    teamName: teamName
    adminPrincipalIds: [ admTeamSid ]
    userPrincipalIds: union(kvAccessAppRegistrations, userPrincipalIds)
  }
}
