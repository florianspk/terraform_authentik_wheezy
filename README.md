# terraform-authentik-wheezy

SSO for the wheezy homelab: [authentik](https://goauthentik.io) users, groups,
OIDC applications and passkey login, managed with Terraform.

## Layout

```
backend.tf        S3 state (Garage), partial config
data.tf           default flows, signing certificate, scopes
identity.tf       groups and users
main.tf           one module instance per OIDC application
passkey.tf        passkey login flow and brand
modules/oauth2-application/
docker/           local authentik for testing
examples/         sample terraform.tfvars
```

## Usage

```bash
cp examples/terraform.tfvars.example terraform.tfvars
export TF_VAR_authentik_url="https://auth.example.com"
export TF_VAR_authentik_token="<api token>"

terraform init -backend-config=backend.hcl
terraform apply
terraform output -json oauth2_applications   # client_id / client_secret per app
```

`backend.hcl` (not committed):

```hcl
bucket     = "terraform-state"
key        = "authentik/terraform.tfstate"
region     = "garage"
endpoints  = { s3 = "http://<garage-host>:3900" }
access_key = "..."
secret_key = "..."
```

The state holds the OIDC client secrets in plaintext.

## Applications

Each entry in `oauth2_applications` creates a confidential OIDC provider and
its application. The client_id is the map key; scopes are `openid email
profile` (the `groups` claim comes with `profile`); redirect URIs are matched
strictly. `restrict_to_groups` limits the app to members of those groups.

OIDC endpoints for an app `<slug>`:

| | |
|---|---|
| Issuer / discovery | `https://auth.example.com/application/o/<slug>/` |
| Authorize | `https://auth.example.com/application/o/authorize/` |
| Token | `https://auth.example.com/application/o/token/` |
| Userinfo | `https://auth.example.com/application/o/userinfo/` |

## Passkey login

With `passkey_login = { domain = "auth.example.com" }`, the login page offers
passkeys through browser autofill and still accepts username + password:

| Sign-in | Result |
|---|---|
| passkey | logged in |
| password, no passkey enrolled | logged in |
| password, passkey enrolled | passkey asked as second factor |

It uses its own brand for that domain, so the default brand and flow are not
modified; removing the variable restores the default login. Users enrol a
passkey from *Settings → MFA Devices → WebAuthn*.

## Local test instance

```bash
./docker/up.sh     # authentik on http://localhost:9000, prints the TF_VAR_* to export
./docker/down.sh   # --purge to wipe it
```

Use a separate working copy without `backend.tf` so the local state never
touches the real one.
