terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }

    jinja = {
      source = "NikolaLohinski/jinja"
      version = "2.3.0"
    }
  }
}

provider "http" {}

data "http" "bamboo" {
  url = "https://registry.terraform.io/v1/providers/yunarta/bamboo"
}

locals {
  versions = jsondecode(data.http.bamboo.response_body)["versions"]
  last_five = slice(local.versions, length(local.versions) - 5, length(local.versions))
}

module "providers" {
  for_each = toset(local.last_five)
  source = "./mod/provider"

  in = "provider.tf.j2"
  out = "output/${each.value}/provider.tf"
  data = each.value
}

output "name" {
  value = module.providers
}