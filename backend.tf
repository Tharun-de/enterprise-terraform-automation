terraform {
  cloud {
    organization = "my-enterprise-terraform-v2"

    workspaces {
      name = "enterprise-automation-v2"
    }
  }
}
