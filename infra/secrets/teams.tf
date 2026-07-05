# Web Secrets
locals {
  web_secrets = {
    for client_id, client in var.team_oidc_clients : client_id => {
      VITE_SERVER_URL = client.env == "local" ? "http://localhost" : "$${{@${client.slug}/server.SERVER_URL}}"
    }
  }
}

resource "vault_kv_secret_v2" "team_web_secrets" {
  for_each  = var.team_oidc_clients
  mount     = vault_mount.kv.path
  name      = "${each.value.slug}/generated/${each.value.env}/web"
  data_json = jsonencode(local.web_secrets[each.key])
}

# Server Secrets
resource "vault_kv_secret_v2" "team_oidc_clients" {
  for_each = var.team_oidc_clients
  mount    = vault_mount.kv.path
  name     = "${each.value.slug}/auth/${each.value.env}"
  data_json = jsonencode(
    {
      client_id     = each.key
      client_secret = var.team_oidc_client_secrets[each.key]
    }
  )
}
