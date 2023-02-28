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
param functionAppSku string = 'Y1'
param functionAppSkuFamily string = 'Y'
param functionAppSkuTier string = 'Dynamic'
param twilioAccountSid string = ''
param twilioAuthToken string = ''
param twilioPhoneNumber string = ''

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
module functionStorageModule 'storageaccount.bicep' = {
  name: '${orgName}-functionstorage${deploymentSuffix}'
  params: {
    storageSku: storageSku
    storageAccountName: resourceNames.outputs.functionStorageName
    location: location
    commonTags: commonTags
  }
}

module functionModule 'functionapp.bicep' = {
  name: '${orgName}-function${deploymentSuffix}'
  params: {
    functionAppName: resourceNames.outputs.functionAppName
    functionAppServicePlanName: resourceNames.outputs.functionAppServicePlanName
    functionInsightsName: resourceNames.outputs.functionInsightsName

    appInsightsLocation: location
    location: location
    commonTags: commonTags

    functionKind: 'functionapp,linux'
    functionAppSku: functionAppSku
    functionAppSkuFamily: functionAppSkuFamily
    functionAppSkuTier: functionAppSkuTier
    functionStorageAccountName: functionStorageModule.outputs.name
  }
}

module dataStorageModule 'storageaccount.bicep' = {
  name: '${orgName}-datastorage${deploymentSuffix}'
  params: {
    storageAccountName: resourceNames.outputs.dataStorageName
    location: location
    commonTags: commonTags
    storageSku: storageSku
  }
}
module keyVaultModule 'keyvault.bicep' = {
  name: '${orgName}-keyvault${deploymentSuffix}'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    location: location
    commonTags: commonTags
    keyVaultOwnerUserId: keyVaultOwnerUserId
    applicationUserObjectIds: [ functionModule.outputs.principalId ]
  }
}
module keyVaultSecret1 'keyvaultsecret.bicep' = {
  name: '${orgName}-keyVaultSecret1${deploymentSuffix}'
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'TwilioAccountSid'
    secretValue: twilioAccountSid
  }
}

module keyVaultSecret2 'keyvaultsecret.bicep' = {
  name: '${orgName}-keyVaultSecret2${deploymentSuffix}'
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'TwilioAuthToken'
    secretValue: twilioAuthToken
  }
}

module keyVaultSecret3 'keyvaultsecret.bicep' = {
  name: '${orgName}-keyVaultSecret3${deploymentSuffix}'
  params: {
    keyVaultName: keyVaultModule.outputs.name
    secretName: 'TwilioPhoneNumber'
    secretValue: twilioPhoneNumber
  }
}
module keyVaultSecret4 'keyvaultsecretstorageconnection.bicep' = {
  name: '${orgName}-keyVaultSecret4${deploymentSuffix}'
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'DataStorageConnectionAppSetting'
    storageAccountName: dataStorageModule.outputs.name
  }
}
module functionAppSettingsModule 'functionappsettings.bicep' = {
  name: '${orgName}-functionAppSettings${deploymentSuffix}'
  params: {
    functionAppName: functionModule.outputs.name
    functionStorageAccountName: functionStorageModule.outputs.name
    functionInsightsKey: functionModule.outputs.insightsKey
    customAppSettings: {
      TwilioAccountSid: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=TwilioAccountSid)'
      TwilioAuthToken: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=TwilioAuthToken)'
      TwilioPhoneNumber: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=TwilioPhoneNumber)'
      DataStorageConnectionAppSetting: '@Microsoft.KeyVault(VaultName=${keyVaultModule.outputs.name};SecretName=DataStorageConnectionAppSetting)'
      IoTHubConnectionString: '@Microsoft.KeyVault(VaultName=${resourceNames.outputs.plantKeyVaultName};SecretName=iotHubConnectionString)'
      IoTStorageConnectionAppSetting: '@Microsoft.KeyVault(VaultName=${resourceNames.outputs.plantKeyVaultName};SecretName=IoTStorageConnectionAppSetting)'
    }
  }
}
