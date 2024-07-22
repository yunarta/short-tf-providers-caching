terraform {
  required_providers {
    jinja = {
      source  = "NikolaLohinski/jinja"
      version = "2.3.0"
    }
  }
}

variable "in" {

}

variable "out" {

}

variable "data" {

}

data "jinja_template" "render" {
  context {
    type = "yaml"
    data = "version: ${var.data}"
  }

  source {
    template  = file("templates/provider.tf.j2")
    directory = "templates"
  }
}

resource "local_file" "render" {
  content  = data.jinja_template.render.result
  filename = var.out
}

locals {
  cwd = path.cwd
}

resource "terraform_data" "execute" {
  triggers_replace = timestamp()
  provisioner "local-exec" {
    command = "echo $TF_PLUGIN_CACHE_DIR && cd ${path.cwd}/output/${var.data} && terraform init"
    environment = {
      TF_PLUGIN_CACHE_DIR = "${local.cwd}/.cache"
    }
  }
}

output "cwd" {
  value = local.cwd
}
