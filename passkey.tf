# Login flow accepting a passkey (WebAuthn autofill) or a password, served on
# its own brand so the default brand and flow stay untouched:
#   10 identification (passkey or username + password)
#   30 MFA validation (skipped after a passkey login)
#   100 login

locals {
  passkey = var.passkey_login == null ? {} : { this = var.passkey_login }
}

data "authentik_brand" "default" {
  for_each = local.passkey
  domain   = "authentik-default"
}

data "authentik_stage" "default" {
  for_each = var.passkey_login == null ? toset([]) : toset([
    "default-authentication-password",
    "default-authentication-mfa-validation",
    "default-authentication-login",
  ])
  name = each.value
}

resource "authentik_stage_authenticator_validate" "passkey" {
  for_each = local.passkey

  name                       = "passkey-authentication-webauthn"
  device_classes             = ["webauthn"]
  not_configured_action      = "deny"
  webauthn_user_verification = "required"
}

resource "authentik_stage_identification" "passkey" {
  for_each = local.passkey

  name                      = "passkey-authentication-identification"
  user_fields               = ["email", "username"]
  case_insensitive_matching = true
  show_matched_user         = true
  pretend_user_exists       = true
  password_stage            = data.authentik_stage.default["default-authentication-password"].id
  webauthn_stage            = authentik_stage_authenticator_validate.passkey[each.key].id
}

resource "authentik_flow" "passkey" {
  for_each = local.passkey

  name        = "Passkey authentication"
  title       = "Welcome to authentik!"
  slug        = "passkey-authentication"
  designation = "authentication"
}

resource "authentik_flow_stage_binding" "passkey" {
  for_each = var.passkey_login == null ? {} : {
    identification = { order = 10, stage = authentik_stage_identification.passkey["this"].id }
    mfa            = { order = 30, stage = data.authentik_stage.default["default-authentication-mfa-validation"].id }
    login          = { order = 100, stage = data.authentik_stage.default["default-authentication-login"].id }
  }

  target               = authentik_flow.passkey["this"].uuid
  stage                = each.value.stage
  order                = each.value.order
  evaluate_on_plan     = false
  re_evaluate_policies = true
}

# The identification stage sets auth_method=auth_webauthn_pwl after a passkey.
resource "authentik_policy_expression" "passkey_skip_mfa" {
  for_each = local.passkey

  name       = "passkey-authentication-skip-mfa-after-passkey"
  expression = "return request.context.get(\"auth_method\") != \"auth_webauthn_pwl\""
}

resource "authentik_policy_binding" "passkey_skip_mfa" {
  for_each = local.passkey

  target = authentik_flow_stage_binding.passkey["mfa"].id
  policy = authentik_policy_expression.passkey_skip_mfa[each.key].id
  order  = 0
}

# authentik_brand manages every field, so copy the default brand's settings.
resource "authentik_brand" "passkey" {
  for_each = local.passkey

  domain              = each.value.domain
  flow_authentication = authentik_flow.passkey[each.key].uuid

  branding_title                   = data.authentik_brand.default[each.key].branding_title
  branding_logo                    = data.authentik_brand.default[each.key].branding_logo
  branding_favicon                 = data.authentik_brand.default[each.key].branding_favicon
  branding_custom_css              = data.authentik_brand.default[each.key].branding_custom_css
  branding_default_flow_background = data.authentik_brand.default[each.key].branding_default_flow_background
  flow_invalidation                = data.authentik_brand.default[each.key].flow_invalidation
  flow_recovery                    = data.authentik_brand.default[each.key].flow_recovery
  flow_unenrollment                = data.authentik_brand.default[each.key].flow_unenrollment
  flow_user_settings               = data.authentik_brand.default[each.key].flow_user_settings
  flow_device_code                 = data.authentik_brand.default[each.key].flow_device_code
  default_application              = data.authentik_brand.default[each.key].default_application
  web_certificate                  = data.authentik_brand.default[each.key].web_certificate
}
