resource "authentik_group" "this" {
  for_each = var.groups

  name = each.key
}

resource "authentik_user" "this" {
  for_each = var.users

  username = each.key
  name     = each.value.name
  email    = each.value.email
  groups   = [for g in each.value.groups : authentik_group.this[g].id]
}
