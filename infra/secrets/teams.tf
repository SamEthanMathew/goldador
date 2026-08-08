locals {
  server_secrets = {
    for client_id, client in var.team_oidc_client_secrets : client_id => {
      AUTH_CLIENT_ID     = client_id
      AUTH_CLIENT_SECRET = client.client_secret
    }
  }
}
resource "vault_kv_secret_v2" "team_server_secrets" {
  for_each  = var.team_oidc_clients
  mount     = vault_mount.kv.path
  name      = "${each.value.slug}/generated/${each.value.env}"
  data_json = jsonencode(local.server_secrets[each.key])
}
