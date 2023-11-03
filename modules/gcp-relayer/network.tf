# Create the VPC network
resource "google_compute_network" "vpc" {
  name                    = local.service_name
  auto_create_subnetworks = false
  mtu                     = 1460
  project                 = var.project_id
  routing_mode            = "GLOBAL"
}

# Create a custom subnet for the Redis instance
resource "google_compute_subnetwork" "default_subnet" {
  ip_cidr_range = var.cidr_default
  depends_on    = [google_compute_network.vpc]
  log_config {
    aggregation_interval = "INTERVAL_30_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  name                       = "${local.service_name}-default"
  network                    = google_compute_network.vpc.id
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = var.project_id
  purpose                    = "PRIVATE"
  region                     = var.region

  stack_type = "IPV4_ONLY"
}

# Create a custom subnet for Cloud Run
resource "google_compute_subnetwork" "cloud_run_subnet" {
  ip_cidr_range = var.cidr_cloudrun
  depends_on    = [google_compute_network.vpc]
  log_config {
    aggregation_interval = "INTERVAL_30_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  name                       = "${local.service_name}-cloudrun"
  network                    = google_compute_network.vpc.id
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = var.project_id
  purpose                    = "PRIVATE"
  region                     = var.region

  stack_type = "IPV4_ONLY"
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = local.service_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  depends_on    = [google_compute_network.vpc]
}

# Create a private connection
# resource "google_service_networking_connection" "default" {
#   network                 = google_compute_network.vpc.id
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
# }

resource "google_vpc_access_connector" "connector" {
  provider = google-beta
  name     = local.service_name
  subnet {
    name = google_compute_subnetwork.cloud_run_subnet.name
  }
  project    = var.project_id
  region     = var.region
  depends_on = [google_compute_subnetwork.cloud_run_subnet]
}


# (Optional) Import or export custom routes
# resource "google_compute_network_peering_routes_config" "peering_routes" {
#   peering = google_service_networking_connection.default.peering
#   network = google_compute_network.vpc.name

#   import_custom_routes = true
#   export_custom_routes = true
# }

# Output the information you may need for your Cloud Run module
output "network_name" {
  value = google_compute_network.vpc.name
}

output "cloud_run_subnet_name" {
  value = google_compute_subnetwork.cloud_run_subnet.name
}

output "redis_subnet_name" {
  value = google_compute_subnetwork.default_subnet.name
}
