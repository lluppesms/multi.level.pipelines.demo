// --------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// --------------------------------------------------------------------------------
param orgName string = ''
param appName string = ''
@allowed(['azd','gha','azdo','dev','demo','qa','stg','ct','prod'])
param environmentCode string = 'dev'

param functionStorageNameSuffix string = 'func'
param dataStorageNameSuffix string = 'data'
param iotStorageNameSuffix string = 'hub'

// --------------------------------------------------------------------------------
var lowerOrgName                         = replace(toLower(orgName), ' ', '')
var sanitizedOrgName                     = replace(replace(lowerOrgName, '-', ''), '_', '')
var lowerAppName                         = replace(toLower(appName), ' ', '')
var sanitizedAppName                     = replace(replace(lowerAppName, '-', ''), '_', '')
var sanitizedEnvironment                 = toLower(environmentCode)

// --------------------------------------------------------------------------------
var functionAppName                      = toLower('${lowerOrgName}-${lowerAppName}-${sanitizedEnvironment}')
var baseStorageName                      = toLower('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}stor')

// --------------------------------------------------------------------------------
output functionAppName string            = functionAppName
output functionAppServicePlanName string = '${functionAppName}-appsvc'
output functionInsightsName string       = '${functionAppName}-insights'
output iotHubName string                 = toLower('${sanitizedOrgName}-${sanitizedAppName}-hub-${sanitizedEnvironment}')
output containerregistryName string      = toLower('${sanitizedOrgName}${sanitizedAppName}acr')

// Key Vaults and Storage Accounts can only be 24 characters long
output keyVaultName string               = take('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}vault', 24)
output plantKeyVaultName string          = take('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}pvault', 24)
output functionStorageName string        = take('${baseStorageName}${functionStorageNameSuffix}', 24)
output dataStorageName string            = take('${baseStorageName}${dataStorageNameSuffix}', 24)
output iotStorageAccountName string      = take(toLower('${sanitizedOrgName}${sanitizedAppName}${sanitizedEnvironment}${iotStorageNameSuffix}'), 24)
