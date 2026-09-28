module "oauth2_applications" {
  source   = "./modules/oauth2-application"
  for_each = var.oauth2_applications

  name          = each.value.name
  slug          = each.key
  group         = each.value.group
  icon          = each.value.icon
  description   = each.value.description
  redirect_uris = each.value.redirect_uris

  authorization_flow_id = data.authentik_flow.authorization.id
  invalidation_flow_id  = data.authentik_flow.invalidation.id
  signing_key_id        = data.authentik_certificate_key_pair.signing.id
  property_mapping_ids  = [for s in data.authentik_property_mapping_provider_scope.scope : s.id]

  restrict_to_group_ids = { for g in each.value.restrict_to_groups : g => authentik_group.this[g].id }
}
