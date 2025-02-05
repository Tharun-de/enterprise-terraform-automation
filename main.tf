variable "okta_api_token" {
  type      = string
  sensitive = true
}

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

# Define an Okta user
resource "okta_user" "example_user" {
  first_name = "John"
  last_name  = "Doe"
  email      = "john.doe@example.com"
  login      = "john.doe@example.com"
  password   = "StrongPassword123!"
}

# Define another Okta user
resource "okta_user" "another_user" {
  first_name = "Jane"
  last_name  = "Smith"
  email      = "jane.smith@example.com"
  login      = "jane.smith@example.com"
  password   = "AnotherSecurePassword123!"
}

# Create an Okta group
resource "okta_group" "engineering_team" {
  name        = "Engineering Team"
  description = "Group for engineering team members"
}

# Assign users to the group
rresource "okta_group_memberships" "engineering_memberships" {
  group_id = okta_group.engineering_team.id
  users    = [
    okta_user.example_user.id,
    okta_user.another_user.id
  ]
}

