# Define sensitive Okta API token
variable "okta_api_token" {
  type      = string
  sensitive = true
}

# Define user data directly as a variable (replace this with CSV later)
variable "users" {
  default = [
    {
      first_name = "John"
      last_name  = "Doe"
      email      = "john.doe@example.com"
      login      = "john.doe@example.com"
      password   = "SecurePass123!"
      group      = "Engineering Team"
    },
    {
      first_name = "Jane"
      last_name  = "Smith"
      email      = "jane.smith@example.com"
      login      = "jane.smith@example.com"
      password   = "AnotherPass456!"
      group      = "Engineering Team"
    },
    {
      first_name = "Alice"
      last_name  = "Johnson"
      email      = "alice.johnson@example.com"
      login      = "alice.johnson@example.com"
      password   = "WelcomePass789!"
      group      = "Finance Team"
    }
  ]
}

# Configure Okta provider
provider "okta" {
  org_name  = "trial-2582192"
  base_url  = "okta.com"
  api_token = var.okta_api_token
}

terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "3.42.0"
    }
  }
}

# Create Okta users from variable data
resource "okta_user" "users" {
  for_each = { for user in var.users : user.email => user }

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password
}

# Create groups based on user data
resource "okta_group" "groups" {
  for_each = toset([for user in var.users : user.group])

  name        = each.value
  description = "Group for ${each.value}"
}

# Assign users to groups
resource "okta_group_memberships" "group_assignments" {
  for_each = { for user in var.users : user.email => user }

  group_id = okta_group.groups[each.value.group].id
  users    = [okta_user.users[each.key].id]
}
