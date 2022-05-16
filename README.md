# Overview

Working notes for setting up an Azure Container Instance as a DNS forwarder. This repository contains a Bicep module and some code to provision an ACI instance as a DNS forwarder within a Vnet. Aswell as some guidance around how to configure each component.

## Requirements

| Component | Requirements |
| -- | -- |
|Azure Container Instance | 1. It must be Linux to be deployed on a Vnet <br> 2. The subnet the ACI instance is deployed into cannot contain any other resource types (e.g. vms). <br> 3. Exporting the ACI instance on port 53 (UDP) |
| Networking | 1. For Hub & Spoke topologies deploy the container instance into a subnet in the Hub vnet. <br> 2. Ensure the Firewall has a network allow rule for UDP port 53 to the ACI subnet for all spoke networks. <br> 4. Once setup add the ACI instance as the DNS server for the Vnet. <br> 5. Ensure the NSG rules on the subnet the ACI instance is in, allows UDP traffic on port 53. <br> 6. Requires the subnet have a service endpoint configured to allow traffic to the Storage Account (for the file share mount). |
| Storage Account - File Share | 1. Create a storage account (or use an existing) and create an Azure File share. |

## Azure Container Instance

To update the named.conf configuration you can use one of the following 2 options:

1. Recreate the container image with the changes to the `named.conf` file and update the ACI image tag.
2. Mount an Azure File share to the container and have the CI system upload on commit changes to the `named.conf` file to the share. Then restart the container or execute a command on the container to reload the config.

## Walkthrough

To deploy the code in this repository, ensure you've met all the requirements outlined in the table above.

1. Create the subnet for the ACI.
2. Create an Azure Fileshare in a new or existing storage account.
3. Update the `deploy.ps1` script with the appropriate variables.
4. Execute the script.

The script will upload the `named.conf` in this repository to your Azure FileShare and deploy the Bicep module into the defined resource group. The Bicep module links ACI to the File share.

## Limitations

- ACI does not run multiple replicas of a container. For production workloads it is recommending to run two containers with ACI to ensure HA.
- Liveness & Readiness probes can't be used on container groups deployed to a virtual network.

## Documentation

- [ACI Limits](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-virtual-network-concepts#other-limitations)
- [az-dns-forwarder GitHub Repo](https://github.com/whiteducksoftware/az-dns-forwarder)
- [ACI FileShare Docs](https://docs.microsoft.com/en-au/azure/container-instances/container-instances-volume-azure-files)