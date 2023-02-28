# Set up an Azure DevOps Variable Groups

To create these variable groups, customize and run this command in the Azure Cloud Shell:

``` bash
az login
$orgName = "<yourAzDOOrg>"
$projectName = "<yourAzDOProject>"
az devops configure -d organization=$orgName project=$projectName

az pipelines variable-group create --authorize false --name MfgApp --variables 
  appName='weather'
  orgName='vbg' 
  location='eastus' 
  containerResourceGroupName='<yourAppResourceGroupName>' 
  serviceConnectionName='<yourServiceConnection>' 
  subscriptionName='<yourAzureSubscriptionName>' 
  subscriptionId='<yourSubscriptionId>' 
  keyVaultOwnerUserId='<optional-owner-SID>'
  functionAppSku='Y1' 
  functionAppSkuFamily='Y' 
  functionAppSkuTier='Dynamic' 
  storageSku='Standard_LRS' 
  
az pipelines variable-group create --name MfgCompany --variables companyName='globalgeo' 

az pipelines variable-group create --name MfgPlantDev --variables 
  plantName='cloudFormation' 
  iotHubName='cumulusHub'
  containerRegistryName='<yourACRName>' 
  resourceGroupPlant='<yourPlantResourceGroupName>' 

az pipelines variable-group create --name MfgLine-Line1-Dev --variables platform='amd64' lineName='thunder' deviceId='boomer1' rate=24 lineAppName='weather1' resourceGroupName='rg_mfgline1_dev'
az pipelines variable-group create --name MfgLine-Line2-Dev --variables platform='x64' lineName='lightning' deviceId='bolt1' rate=12 lineAppName='weather2' resourceGroupName='rg_mfgline2_dev'
az pipelines variable-group create --name MfgLine-Line3-Dev --variables platform='x86' lineName='cyclone' deviceId='windy1' rate=128 lineAppName='weather3' resourceGroupName='rg_mfgline3_dev'

az pipelines variable-group create --name MfgPlantQA --variables 
  plantName='mountainRange' 
  iotHubName='rangeHub'
  containerRegistryName='<yourACRName>' 
  resourceGroupPlant='<yourPlantResourceGroupName>' 

az pipelines variable-group create --name MfgLine-Line1-QA --variables platform='amd64' lineName='alaska' deviceId='denali1' rate=20310 lineAppName='weather1' resourceGroupName='rg_mfgline1_qa'
az pipelines variable-group create --name MfgLine-Line2-QA --variables platform='x64' lineName='himalayas' deviceId='everest1' rate=29029 lineAppName='weather2' resourceGroupName='rg_mfgline2_qa'
az pipelines variable-group create --name MfgLine-Line3-QA --variables platform='x86' lineName='japan' deviceId='fuji1' rate=12389 lineAppName='weather3' resourceGroupName='rg_mfgline3_qa'
```
