terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "3.42.0"
    }
  }
}

provider "okta" {
  org_name  = "trial-2582192"
  base_url  = "okta.com"
  api_token = var.okta_api_token
}

variable "okta_api_token" {
  type      = string
  sensitive = true
}

variable "users" {
  type = map(object({
    first_name  = string
    last_name   = string
    email       = string
    role        = string
  }))
}

# Create Okta users
resource "okta_user" "users" {
  for_each = var.users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = each.value.email
  email      = each.value.email
  status     = "ACTIVE"
}

# Create Okta groups
resource "okta_group" "groups" {
  for_each = toset(["Admin Group", "App Admin Group", "Standard Users"])

  name        = each.value
  description = "Group for ${each.value}"
}

# Assign users to groups
resource "okta_group_memberships" "group_assignments" {
  for_each = var.users

  group_id = okta_group.groups[each.value.role].id
  users    = [okta_user.users[each.key].id]
}

# **Assign Okta roles to users using okta_role_assignment**
resource "okta_role_assignment" "user_roles" {
  for_each = var.users

  user_id = okta_user.users[each.key].id
  role    = lookup({
    "Admin Group"       = "ORG_ADMIN",
    "App Admin Group"   = "APP_ADMIN",
    "Standard Users"    = "USER"
  }, each.value.role, "USER") # Default to USER role if none specified
}
