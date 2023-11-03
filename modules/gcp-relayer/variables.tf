variable "project_id" {
  description = "The default project id to use for resources in this directory."
  type        = string
}

variable "network" {
  description = "mainnet or testnet"
  type        = string
  validation {
    condition     = contains(["mainnet", "testnet"], var.network)
    error_message = "Allowed values for network are mainnet or testnet"
  }
}

variable "relayer_name" {
  description = "name for relayer ex: near-relayer"
  type        = string
  default = "relayer"

}
locals {
  service_name = "${var.network}-relayer-${var.relayer_name}"
}


variable "region" {
  type = string
}

# network variables
variable "cidr_cloudrun" {
  description = "CIDR range for cloud run subnet. Must have a /28 mask"
  type        = string
  default     = "173.24.128.0/28"
}

variable "cidr_default" {
  description = "CIDR range for default subnet"
  type        = string
  default     = "173.24.129.0/24"
}

#relayer container variables
variable "config_file_path" {
  description = "File path for relayer config file"
  type        = string
}

variable "account_key_file_paths" {
  description = "List of file paths with account keys for relayer"
  type        = list(string)
}
variable "docker_image" {
  description = "Docker image for relayer"
  type        = string
}

# redis variables
variable "redis_instance" {
  type    = bool
  default = false
}

variable "redis_auth" {
  type        = bool
  default     = false
  description = "Password authentication for redis. \nIf you turn this on, you will have to put the redis password in the confit.toml \nin the redis connection string and rerun terraform to create a new revision of the cloud run service"
}

variable "redis_memory_size_gb" {
  description = "Redis instance memory size"
  default     = 5
}

variable "redis_replica_count" {
  type    = number
  default = 1
}

variable "transit_encryption_mode" {
  type    = string
  default = "SERVER_AUTHENTICATION"
  validation {
    condition     = contains(["DISABLED", "SERVER_AUTHENTICATION"], var.transit_encryption_mode)
    error_message = "Allowed values for transit_encryption_mode are DISABLED or SERVER_AUTHENTICATION"
  }
}
