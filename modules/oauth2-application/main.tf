resource "authentik_provider_oauth2" "this" {
  name        = var.name
  client_id   = var.slug
  client_type = "confidential"
  grant_types = ["authorization_code", "refresh_token"]

  access_token_validity = "hours=1"

  allowed_redirect_uris = [
    for uri in var.redirect_uris : {
      matching_mode     = "strict"
      url               = uri
      redirect_uri_type = "authorization" # API default, set to avoid a perpetual diff
    }
  ]

  property_mappings  = var.property_mapping_ids
  authorization_flow = var.authorization_flow_id
  invalidation_flow  = var.invalidation_flow_id
  signing_key        = var.signing_key_id
}

resource "authentik_application" "this" {
  name              = var.name
  slug              = var.slug
  group             = var.group
  meta_icon         = var.icon
  meta_description  = var.description
  protocol_provider = authentik_provider_oauth2.this.id
}

resource "authentik_policy_binding" "restrict" {
  for_each = var.restrict_to_group_ids

  target = authentik_application.this.uuid
  group  = each.value
  order  = index(keys(var.restrict_to_group_ids), each.key)
}
