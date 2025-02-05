# Define Okta API token as a sensitive variable
variable "okta_api_token" {
  type      = string
  sensitive = true
}

# Configure the Okta provider
provider "okta" {
  org_name  = "trial-2582192"  # Replace with your Okta org name
  base_url  = "okta.com"
  api_token = var.okta_api_token
}

# Terraform provider configuration
terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "3.42.0"
    }
  }
}

# Manually define users and their assigned groups
variable "users" {
  default = {
    "xyz.admin@example.com" = {
      first_name = "XYZ"
      last_name  = "Admin"
      email      = "xyz.admin@example.com"
      login      = "xyz.admin@example.com"
      password   = "XYZPassAdmin123!"
      group      = "Admin Group"
      role       = "SUPER_ADMIN"
    },
    "xyz.appadmin@example.com" = {
      first_name = "XYZ"
      last_name  = "AppAdmin"
      email      = "xyz.appadmin@example.com"
      login      = "xyz.appadmin@example.com"
      password   = "XYZPassApp123!"
      group      = "App Admin Group"
      role       = "APP_ADMIN"
    },
    "xyz.user@example.com" = {
      first_name = "XYZ"
      last_name  = "User"
      email      = "xyz.user@example.com"
      login      = "xyz.user@example.com"
      password   = "XYZPassUser123!"
      group      = "Standard Users"
      role       = "READ_ONLY_ADMIN"
    }
  }
}

# CREATE Okta users dynamically
resource "okta_user" "users" {
  for_each = var.users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password
}

# CREATE Okta groups dynamically based on assigned roles
resource "okta_group" "groups" {
  for_each = toset([for user in var.users : user.group])

  name        = each.value
  description = "Group for ${each.value}"
}

# ASSIGN users to groups dynamically
resource "okta_group_memberships" "group_assignments" {
  for_each = var.users

  group_id = okta_group.groups[each.value.group].id
  users    = [okta_user.users[each.key].id]
}

# CREATE Okta role assignments dynamically
resource "okta_admin_role" "role_assignments" {
  for_each = var.users

  user_id = okta_user.users[each.key].id
  role    = each.value.role
}
