// --------------------------------------------------------------------------------
// Main Bicep file that creates all of the Azure Resources for one environment
// --------------------------------------------------------------------------------
// To deploy this Bicep manually:
// 	 az login
//   az account set --subscription <subscriptionId>
//
//   Test azd deploy:
//     az deployment group create -n main-deploy-20221115T150000Z --resource-group rg_durable_azd  --template-file 'main.bicep' --parameters appName=lll-dur-azd environmentCode=azd keyVaultOwnerUserId=xxxxxxxx-xxxx-xxxx
//   Test AzDO Pipeline deploy:
//     az deployment group create -n main-deploy-20221115T150000Z --resource-group rg_durable_azdo --template-file 'main.bicep' --parameters appName=lll-dur-dev environmentCode=dev keyVaultOwnerUserId=xxxxxxxx-xxxx-xxxx
// --------------------------------------------------------------------------------
param orgName string = 'xxx'
param appName string = 'durabledemo'
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environmentCode string = 'dev'
param location string = resourceGroup().location
param keyVaultOwnerUserId string = ''

// optional parameters
@allowed(['Standard_LRS','Standard_GRS','Standard_RAGRS'])
param storageSku string = 'Standard_LRS'

param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = runDateTime == null ? '' : '-${runDateTime}'
var commonTags = {         
  LastDeployed: runDateTime
  Organization: orgName
  Application: appName
  Environment: environmentCode
}

// --------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: '${orgName}-resourcenames${deploymentSuffix}'
  params: {
    orgName: orgName
    appName: appName
    environmentCode: environmentCode
    functionStorageNameSuffix: 'func'
    dataStorageNameSuffix: 'data'
    iotStorageNameSuffix: 'hub'
  }
}

// --------------------------------------------------------------------------------
module iotStorageModule 'storageaccount.bicep' = {
  name: '${orgName}-iotstorage${deploymentSuffix}'
  params: {
    storageAccountName: resourceNames.outputs.iotStorageAccountName
    location: location
    commonTags: commonTags
    storageSku: storageSku
  }
}
module iotHubModule 'iothub.bicep' = {
  name: '${orgName}-iotHub${deploymentSuffix}'
  params: {
    iotHubName: resourceNames.outputs.iotHubName
    iotStorageAccountName: iotStorageModule.outputs.name
    iotStorageContainerName: 'iothubuploads'
    location: location
    commonTags: commonTags
  }
}
module keyVaultModule 'keyvault.bicep' = {
  name: '${orgName}-keyvault${deploymentSuffix}'
  params: {
    keyVaultName: resourceNames.outputs.plantKeyVaultName
    location: location
    commonTags: commonTags
    keyVaultOwnerUserId: keyVaultOwnerUserId
  }
}

module keyVaultSecretIoT1 'keyvaultsecretiothubconnection.bicep' = {
  name: '${orgName}-keyVaultSecretIoT1${deploymentSuffix}'
  dependsOn: [ iotHubModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'iotHubConnectionString'
    iotHubName: iotHubModule.outputs.name
  }
}
module keyVaultSecretIoT2 'keyvaultsecretstorageconnection.bicep' = {
  name: '${orgName}-keyVaultSecretIoT2${deploymentSuffix}'
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'IoTStorageConnectionAppSetting'
    storageAccountName: iotStorageModule.outputs.name
  }
}
