locals {
  instance_names = {
    for name, count in var.instance_counts : name => [
      for i in range(1, count+1) : format("%s-%02d", name, i)
    ]
  }
}

# Get CloudInit user data info
data "template_file" "user_data" {
  template = file("${path.module}/../../config/cloud_init.yml")
}

# Create kubernetes worker profile
resource "lxd_profile" "worker_config" {
  name        = "kubernetes_worker_config"
  description = "Kubernetes worker LXC container"

  config = {
    "limits.cpu"           = 2
    "limits.memory"        = "2046MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
  }
}

# Create kubernetes worker containers
resource "lxd_container" "kubernetes_workers" {
  for_each   = toset(local.instance_names.kubernetes-worker)
  name       = each.key
  image      = "ubuntu:22.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.worker_config.name]
}
