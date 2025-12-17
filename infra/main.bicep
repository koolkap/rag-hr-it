// ================================
// Subscription-scoped deployment
// ================================
targetScope = 'subscription'

@description('Azure region')
param location string = 'eastus2'

@description('Project prefix (lowercase, alphanumeric)')
param projectPrefix string = 'raghr'

var rgName = '${projectPrefix}-rg'
var storageAccountName = toLower('${projectPrefix}sa')
var searchServiceName = toLower('${projectPrefix}-search')
var openAiName = toLower('${projectPrefix}-openai')

/* Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
}

/* Storage Account */
resource storage 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  scope: rg
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

/* Blob Container */
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  name: '${storage.name}/default/documents'
  scope: rg
  properties: {
    publicAccess: 'None'
  }
}

/* Azure AI Search */
resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  scope: rg
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
  }
}

/* Azure OpenAI (Foundry compatible) */
resource openai 'Microsoft.CognitiveServices/accounts@2023-10-01' = {
  name: openAiName
  scope: rg
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {}
}

/* Outputs */
output resourceGroupName string = rg.name
output storageAccountName string = storage.name
output blobContainerName string = 'documents'
output searchEndpoint string = search.properties.searchServiceEndpoint
output openAiEndpoint string = openai.properties.endpoint
