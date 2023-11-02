variable "project_id" {
  description = "The default project id to use for resources in this directory."
  type = string
}

variable "network" {
  description = "mainnet or testnet"
 type = string
  validation {
    condition     = contains(["mainnet", "testnet"], var.network)
    error_message = "Allowed values for network are mainnet or testnet"
  }
}

variable "relayer_name" {
  description = "name for relayer ex: near-relayer"
  type = string

}
locals {
  service_name = "${var.network}-relayer-${var.relayer_name}"
}


variable "region" {
  type = string
}

variable "cidr_cloudrun" {
  description = "CIDR range for cloud run subnet. Must have a /28 mask"
  type = string
  default = "173.24.128.0/28"
}

variable "cidr_default" {
  description = "CIDR range for default subnet"
  type = string
  default = "173.24.129.0/24"
}

variable "config_file_path" {
  description = "File path for relayer config file"
  type = string
}

variable "account_key_file_paths" {
  description = "List of file paths with account keys for relayer"
  type = list(string)
}
variable "docker_image" {
  description = "Docker image for relayer"
  type = string
}
