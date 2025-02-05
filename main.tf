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

# Manually define users (NO CSV, NO JANE/ALICE, ADDED XYZ USER)
variable "users" {
  default = {
    "xyz.user1@example.com" = {
      first_name = "XYZ1"
      last_name  = "User1"
      email      = "xyz.user1@example.com"
      login      = "xyz.user1@example.com"
      password   = "XYZPass123!"
      group      = "XYZ Group"
    },
    "xyz.user2@example.com" = {
      first_name = "XYZ2"
      last_name  = "User2"
      email      = "xyz.user2@example.com"
      login      = "xyz.user2@example.com"
      password   = "XYZPass456!"
      group      = "XYZ Group"
    }
  }
}

# CREATE new Okta users
resource "okta_user" "users" {
  for_each = var.users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password
}

# CREATE XYZ Group
resource "okta_group" "xyz_group" {
  name        = "XYZ Group"
  description = "Group for XYZ Users"
}

# ASSIGN users to XYZ Group
resource "okta_group_memberships" "group_assignments" {
  for_each = var.users

  group_id = okta_group.xyz_group.id
  users    = [okta_user.users[each.key].id]
}
