terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "3.42.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
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

# Ensure 'requests' module is installed
resource "null_resource" "install_requests" {
  provisioner "local-exec" {
    command = "pip3 install requests --user"
  }
}

# Assign roles using an external Python script
data "external" "assign_roles" {
  for_each = var.users

  depends_on = [null_resource.install_requests] # Ensure 'requests' is installed first

  program = ["/usr/bin/python3", "${path.module}/assign_roles.py"]

  query = {
    email = each.value.email
    role  = each.value.role
  }
}

resource "okta_user" "users" {
  for_each = var.users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = each.value.email
  email      = each.value.email
  status     = "ACTIVE"
}

resource "okta_group" "groups" {
  for_each = toset(["Admin Group", "App Admin Group", "Standard Users"])

  name        = each.value
  description = "Group for ${each.value}"
}

resource "okta_group_memberships" "group_assignments" {
  for_each = var.users

  group_id = okta_group.groups[each.value.role].id
  users    = [okta_user.users[each.key].id]
}
