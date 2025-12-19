resource "tailscale_tailnet_settings" "sample_tailnet_settings" {
  acls_externally_managed_on                  = var.acls_externally_managed_on
  acls_external_link                          = var.acls_external_link
  devices_approval_on                         = var.devices_approval_on
  devices_auto_updates_on                     = var.devices_auto_updates_on
  devices_key_duration_days                   = var.devices_key_duration_days
  users_approval_on                           = var.users_approval_on
  users_role_allowed_to_join_external_tailnet = var.users_role_allowed_to_join_external_tailnet
  posture_identity_collection_on              = var.posture_identity_collection_on
  https_enabled                               = var.https_enabled
}
