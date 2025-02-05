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

# External data source to read users.csv
data "external" "csv_users" {
  program = ["python3", "${path.module}/parse_csv.py"]
}

# CREATE new Okta users from CSV data (after decoding JSON)
resource "okta_user" "users" {
  for_each = { for email, user in data.external.csv_users.result.users : email => jsondecode(user) }

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password
}

# CREATE Okta groups dynamically based on CSV data
resource "okta_group" "groups" {
  for_each = toset([for user in data.external.csv_users.result.users : jsondecode(user).group])

  name        = each.value
  description = "Group for ${each.value}"
}

# ASSIGN users to their respective groups
resource "okta_group_memberships" "group_assignments" {
  for_each = { for email, user in data.external.csv_users.result.users : email => jsondecode(user) }

  group_id = okta_group.groups[each.value.group].id
  users    = [okta_user.users[each.key].id]
}
