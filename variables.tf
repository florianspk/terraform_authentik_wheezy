variable "authentik_url" {
  type = string
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "groups" {
  type    = set(string)
  default = []
}

variable "users" {
  type = map(object({
    name   = string
    email  = string
    groups = optional(list(string), [])
  }))
  default = {}
}

variable "oauth2_applications" {
  type = map(object({
    name               = string
    group              = optional(string, "")
    icon               = optional(string, "")
    description        = optional(string, "")
    redirect_uris      = list(string)
    restrict_to_groups = optional(list(string), [])
  }))
  default = {}
}
