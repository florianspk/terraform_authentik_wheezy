output "oauth2_applications" {
  value = {
    for k, m in module.oauth2_applications : k => {
      client_id     = m.client_id
      client_secret = m.client_secret
    }
  }
  sensitive = true
}
