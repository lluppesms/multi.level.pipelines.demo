// --------------------------------------------------------------------------------
// This BICEP file will create storage account
// --------------------------------------------------------------------------------
// To deploy this Bicep manually:
// 	 az login   (do this if not already logged in)
//   az account set --subscription 1bd3dfe5-ddd8-443c-8d35-31cf3d729c8f
//   az deployment group create -n lll-storage -g RG-BICEP-WORKSHOP-01 -f 'storageaccount.bicep' -p storageAccountName=lllstoragedemo
// --------------------------------------------------------------------------------
param storageAccountName string = 'mystorageaccountname'
param location string = resourceGroup().location
param commonTags object = {}

@allowed([ 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS' ])
param storageSku string = 'Standard_LRS'
param storageAccessTier string = 'Hot'

// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~storageAccount.bicep' }
var tags = union(commonTags, templateTag)

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    sku: {
        name: storageSku
    }
    tags: tags
    kind: 'StorageV2'
    properties: {
        networkAcls: {
            bypass: 'AzureServices'
            virtualNetworkRules: []
            ipRules: []
            defaultAction: 'Allow'
            // defaultAction: 'Deny' // - security rules want 'Deny', but that makes the app deploy break...!
        }
        supportsHttpsTrafficOnly: true
        encryption: {
            services: {
                file: {
                    keyType: 'Account'
                    enabled: true
                }
                blob: {
                    keyType: 'Account'
                    enabled: true
                }
            }
            keySource: 'Microsoft.Storage'
        }
        accessTier: storageAccessTier
        allowBlobPublicAccess: false
        minimumTlsVersion: 'TLS1_2'
    }
}

resource blobServiceResource 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
    name: '${storageAccountResource.name}/default'
    properties: {
        cors: {
            corsRules: [
            ]
        }
        deleteRetentionPolicy: {
            enabled: true
            days: 7
        }
    }
}

output id string = storageAccountResource.id
output name string = storageAccountResource.name
