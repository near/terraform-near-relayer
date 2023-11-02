resource "google_cloud_run_service" "relayer_cloudrun" {
  name                       = local.service_name
  location                   = var.region
  project                    = var.project_id
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email
      containers {
        image = var.docker_image
        ports {
          name           = "http1"
          container_port = 3030
        }

        volume_mounts {
          mount_path = "/relayer-app"
          name       = "config"
        }

        dynamic "volume_mounts" {
          for_each = var.account_key_file_paths
          content {
            mount_path = "/relayer-app/account_keys/${volume_mounts.key}"
            name       = "key_${volume_mounts.key}"
          }
        }

        resources {
          limits = {
            memory = "1Gi"
            cpu : "2000m" # 2 cores.
          }
        }
      }

      volumes {
        name = "config"
        secret {
          secret_name = google_secret_manager_secret.config.secret_id
          items {
            key  = "latest"
            path = "config.toml"
          }
        }
      }

      dynamic "volumes" {
        for_each = var.account_key_file_paths
        content {
          name = "key_${volumes.key}"
          secret {
            secret_name = google_secret_manager_secret.account_key_secrets[volumes.key].secret_id
            items {
              key  = "latest"
              path = "key-${volumes.key}.json"
            }
          }
        }
      }

    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"         = "5"
        "run.googleapis.com/cpu-throttling"        = false
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/vpc-access-connector"  = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"     = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }


  depends_on = [
    google_secret_manager_secret.config,
    google_service_account.cloud_run_sa,
    google_secret_manager_secret_iam_member.secret_access,
    google_vpc_access_connector.connector,
  ]

    # Ignore changes in image and revision.
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].containers[0].resources,
      template[0].metadata[0].annotations,
    ]
  }

}
