resource "google_secret_manager_secret" "config" {
  secret_id = "${local.service_name}-config"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "config_secret_version" {
  secret      = google_secret_manager_secret.config.name
  secret_data = file("${var.config_file_path}")

  depends_on = [google_secret_manager_secret.config]
}

resource "google_secret_manager_secret" "account_key_secrets" {
  count = length(var.account_key_file_paths)

  secret_id = "${local.service_name}-key-${count.index}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "account_secret_versions" {
  count   = length(var.account_key_file_paths)
  secret = google_secret_manager_secret.account_key_secrets[count.index].name
  secret_data =file(var.account_key_file_paths[count.index])
}

output "secret_names" {
  value = google_secret_manager_secret.account_key_secrets[*].name
}