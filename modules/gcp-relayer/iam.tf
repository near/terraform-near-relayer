# Service accounts for running cloud run service

# tetsnet
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${local.service_name}-sa"
  display_name = "${local.service_name}-cloud-run-sa"
}

resource "google_cloud_run_service_iam_member" "sa_iam_admin" {
  location = var.region
  service  = local.service_name
  role     = "roles/run.admin"
  member   = "serviceAccount:${google_service_account.cloud_run_sa.email}"

  depends_on = [google_cloud_run_service.relayer_cloudrun]
}

# Allow unauthenticated users to invoke services.
resource "google_cloud_run_service_iam_member" "sa_unauth_invoker" {
  location = var.region
  service  = google_cloud_run_service.relayer_cloudrun.name
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [google_cloud_run_service.relayer_cloudrun]
}

# locals {
#   testnet_secret_ids = [
#     "testnet-relayer-nomnomnom-key",
#     "testnet-relayer-key-1",
#     "testnet-relayer-key-2",
#     "testnet-relayer-key-3",
#     "testnet-relayer-key-4",
#     "testnet-relayer-key-5",
#   ]
#   mainnet_secret_ids = [
#     "mainnet-relayer-key",
#     "mainnet-relayer-key-1",
#     "mainnet-relayer-key-2",
#     "mainnet-relayer-key-3",
#     "mainnet-relayer-key-4",
#     "mainnet-relayer-key-5",
#   ]
# }

# locals {
#   secret_ids = var.network == "testnet" ? local.testnet_secret_ids : var.network == "mainnet" ? local.mainnet_secret_ids : []
# }

resource "google_secret_manager_secret_iam_member" "secret_access" {
  count = length(var.account_key_file_paths)

  secret_id  = "${local.service_name}-key-${count.index}"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.cloud_run_sa.email}"
  depends_on = [google_secret_manager_secret.account_key_secrets]
}

resource "google_secret_manager_secret_iam_member" "config_secret_access" {
  secret_id  = google_secret_manager_secret.config.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.cloud_run_sa.email}"
  depends_on = [google_secret_manager_secret.config]
}
