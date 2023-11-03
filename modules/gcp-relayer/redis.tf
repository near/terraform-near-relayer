resource "google_service_networking_connection" "private_service_connection" {
  count                   = var.redis_instance ? 1 : 0
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

resource "google_dns_managed_zone" "private-zone" {
  count       = var.redis_instance ? 1 : 0
  name        = local.service_name
  dns_name    = local.service_name
  description = "DNS zone for internal ${local.service_name}"
  labels = {
    service         = local.service_name
    cost_allocation = "all"
  }

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

resource "google_redis_instance" "redis_instance" {
  count                   = var.redis_instance ? 1 : 0
  auth_enabled            = var.redis_auth
  authorized_network      = google_compute_network.vpc.id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  display_name            = local.service_name
  memory_size_gb          = var.redis_memory_size_gb
  name                    = local.service_name
  project                 = var.project_id
  read_replicas_mode      = "READ_REPLICAS_ENABLED"
  redis_version           = "REDIS_6_X"
  region                  = var.region
  replica_count           = var.redis_replica_count
  tier                    = "STANDARD_HA"
  transit_encryption_mode = var.transit_encryption_mode

  depends_on = [google_service_networking_connection.private_service_connection]

}

resource "google_dns_record_set" "a" {
  count        = var.redis_instance ? 1 : 0
  name         = "redis.${local.service_name}"
  project      = var.project_id
  managed_zone = google_dns_managed_zone.private-zone[count.index].id
  type         = "A"
  ttl          = 300
  rrdatas      = [google_redis_instance.redis_instance[count.index].host]
  depends_on   = [google_redis_instance.redis_instance]
}
