# Define sensitive Okta API token variable
variable "okta_api_token" {
  type      = string
  sensitive = true
}

# Configure the Okta provider
provider "okta" {
  org_name  = "trial-2582192"
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

# External data source to read users.csv
data "external" "csv_users" {
  program = ["python3", "${path.module}/parse_csv.py"]
}

# Retrieve existing Okta users to delete them first
data "okta_users" "existing_users" {}

# Delete all existing users in Okta before re-creating them
resource "okta_user" "delete_users" {
  for_each = { for user in data.okta_users.existing_users.users : user.id => user }

  id = each.key

  lifecycle {
    prevent_destroy = false
  }
}

# Retrieve existing Okta groups to delete them before recreating
data "okta_groups" "existing_groups" {}

# Delete all existing groups in Okta before re-creating them
resource "okta_group" "delete_groups" {
  for_each = { for group in data.okta_groups.existing_groups.groups : group.id => group }

  id = each.key

  lifecycle {
    prevent_destroy = false
  }
}

# Wait for deletion to complete before creating new users and groups
resource "null_resource" "wait_for_deletion" {
  depends_on = [okta_user.delete_users, okta_group.delete_groups]
}

# Create Okta users from CSV data
resource "okta_user" "users" {
  for_each = { for user in data.external.csv_users.result.users : user.email => user }

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password

  depends_on = [null_resource.wait_for_deletion]
}

# Create Okta groups dynamically from CSV data
resource "okta_group" "groups" {
  for_each = toset([for user in data.external.csv_users.result.users : user.group])

  name        = each.value
  description = "Group for ${each.value}"

  depends_on = [null_resource.wait_for_deletion]
}

# Assign users to groups dynamically
resource "okta_group_memberships" "group_assignments" {
  for_each = { for user in data.external.csv_users.result.users : user.email => user }

  group_id = okta_group.groups[each.value.group].id
  users    = [okta_user.users[each.key].id]
}
