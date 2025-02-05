# Define the sensitive Okta API token variable
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

# Dynamically create Okta users from the CSV file
resource "okta_user" "users" {
  for_each   = { for user in data.external.csv_users.result.users : user.email => user }

  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email
  login      = each.value.login
  password   = each.value.password
}

# Create Okta groups based on CSV input (optional example)
resource "okta_group" "groups" {
  for_each = toset([for user in data.external.csv_users.result.users : user.group])

  name        = each.value
  description = "Group for ${each.value}"
}

# Assign users to groups dynamically
resource "okta_group_memberships" "group_assignments" {
  for_each = { for user in data.external.csv_users.result.users : user.email => user }

  group_id = okta_group.groups[each.value.group].id
  users    = [okta_user.users[each.key].id]
}
