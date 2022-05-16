
## Variables for the Storage Account upload
$storageAccountResourceGroupName = ''
$fileShareName = ''
$storageAccName = ''
$fileName = 'named.conf'


## Upload the local `named.conf` file to the Azure File share (which is mounted by the ACI container)
$ctx = (Get-AzStorageAccount -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccName).Context
Set-AzStorageFileContent -ShareName $fileShareName -Source $fileName -Path '/' -Force -Context $ctx


## ACI components
## Variables
$aciResourceGroupName = 'aci-dns'
New-AzResourceGroupDeployment -ResourceGroupName $aciResourceGroupName `
    -TemplateFile template.bicep `
    -storageAccountName $storageAccName `
    -azureFileShareName $fileShareName `
    -storageAccountResourceGroup $storageAccountResourceGroupName `
    -vnetName '' `
    -subnetName '' `
    -vnetResourceGroupName ''
    