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
module containerRegistry 'containerregistry.bicep' = {
  name: '${orgName}-registry${deploymentSuffix}'
  params: {
    containerRegistryName: resourceNames.outputs.containerregistryName
    location: location
    skuName: 'Premium'
    commonTags: commonTags
  }
}
