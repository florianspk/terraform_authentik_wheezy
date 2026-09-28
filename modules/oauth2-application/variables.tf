variable "name" {
  type = string
}

variable "slug" {
  type = string
}

variable "group" {
  type = string
}

variable "icon" {
  type = string
}

variable "description" {
  type = string
}

variable "redirect_uris" {
  type = list(string)
}

variable "authorization_flow_id" {
  type = string
}

variable "invalidation_flow_id" {
  type = string
}

variable "signing_key_id" {
  type = string
}

variable "property_mapping_ids" {
  type = list(string)
}

variable "restrict_to_group_ids" {
  type = map(string)
}
