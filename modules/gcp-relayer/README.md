# gcp-relayer

## Overview
This module provides an infrastructure deployment solution for running a Near Protocol Relayer on Google Cloud Platform (GCP). It creates necessary resources, including a Google CloudRun service, VPC, secrets for storing account keys and configuration.

### Note: Does not support fastauth functionality yet.

## Prerequisites
Before using this Terraform module, you should have the following prerequisites in place:

- A Google Cloud Platform (GCP) project.
- Google Cloud SDK installed and configured.
- Terraform installed on your local machine.

## Usage
### Module Configuration



| Variable Name | Description | Type | Default Value | Required |
| --- | --- | --- | --- | --- |
| `project_id` | The GCP Project where resources will be deployed. | `string` | - | Yes |
| `network` | Near Protocol Network you want the relayer for <mainnet \| testnet>. | `string` | - | Yes |
| `relayer_name` | Relayer service name. This will be used as a prefix to create all resources. | `string` | relayer | No |
| `region` | GCP region. | `string` | - | Yes |
| `docker_image` | The Near Protocol relayer image you want to run. Refer to https://github.com/near/pagoda-relayer-rs/pkgs/container/os-relayer for version history. | `string` | - | Yes |
| `cidr_cloudrun` | CIDR range for cloud run subnetwork. Make sure this doesn't conflict with any other subnets in your project/organization. Must have a /28 mask. | `string` | "173.25.128.0/28" | No |
| `cidr_default` | CIDR range for default relayer subnetwork. Make sure this doesn't conflict with any other subnets in your project/organization. | `string` | "173.25.129.0/28" | No |
| `config_file_path` | File path to you config.toml file that has your required relayer config. This will be stored in a secrets manager secret. | `string` | - | Yes |
| `account_key_file_paths` | A list of file paths that hold your account keys you want to use for the relayer. These will be stored in secrets. manager secret. | `List(string)` | - | Yes |


### Example
```
module "near_relayer" {
    source           = "github.com/near/terraform-near-relayer/modules/gcp-relayer 
    project_id       = relayer-project
    network          = "mainnet"
    relayer_name     = "relayer"
    region           = "us-central1"
    docker_image     = "us-central1-docker.pkg.dev/pagoda-discovery-platform-dev/cloud-run-source-deploy/os-relayer:latest"
    cidr_cloudrun    = "173.25.128.0/28"
    cidr_default     = "173.25.129.0/28"
    config_file_path = "/Users/anshalsavla/Documents/near/terraform-near-relayer/examples/gcp-relayer-basic/config.toml"
    account_key_file_paths = ["/home/relayer_keys/key_1.json",
                              "/home/relayer_keys/key_2.json",
                              "/home/relayer_keys/key_3.json",]
}
```

Check terraform-near-relayer/examples for different configuration examples. 

### Example of config file

```
ip_address = [0, 0, 0, 0]
port = 3030
relayer_account_id = "nomnomnom.testnet"
keys_filenames = ["/relayer-app/account_keys/0/key-0.json",  "/relayer-app/account_keys/1/key-1.json", "/relayer-app/account_keys/2/key-2.json"]
whitelisted_contracts = ["guest-book.testnet"]
use_redis = false
use_fastauth_features = false
use_shared_storage = false
network = "testnet"
rpc_url = "https://archival-rpc.testnet.near.org"
wallet_url = "https://wallet.testnet.near.org"
explorer_transaction_url = "https://explorer.testnet.near.org/transactions/"
rpc_api_key = ""
```

### Note
`keys_filenames` in `config.toml`
These file paths are the container mounts and not your local file paths.
They should look like this: `["/relayer-app/account_keys/<count 0:n>/key-<count 0:n>.json"]`