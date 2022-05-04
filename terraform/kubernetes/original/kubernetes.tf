locals {
  kubernetes_names = {
    for name, count in var.kubernetes_counts : name => [
      for i in range(1, count+1) : format("%s-%02d", name, i)
    ]
  }
}

# Get CloudInit user data info
data "template_file" "user_data" {
  template = file("${path.module}/../config/cloud_init.yml")
}

# Create master container profile
resource "lxd_profile" "config" {
  name        = "kubernetes_config"
  description = "Kubernetes LXC container"

  config = {
    "limits.cpu"           = 4
    "limits.memory"        = "8192MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
    "security.privileged"  = 1
    "security.nesting"     = 1
    "boot.autostart"       = 1
    "linux.kernel_modules" = "ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter"
    "raw.lxc"              = <<EOF
lxc.apparmor.profile=unconfined
lxc.mount.auto=proc:rw sys:rw cgroup:rw
lxc.cgroup.devices.allow=a
lxc.cap.drop=
EOF
  }

  device {
    name = "aadisable"
    type = "disk"
    properties = {
      path   = "/sys/module/nf_conntrack/parameters/hashsize"
      source = "/sys/module/nf_conntrack/parameters/hashsize"
    }
  }
  device {
    name = "aadisable1"
    type = "disk"
    properties = {
      path   = "/sys/module/apparmor/parameters/enabled"
      source = "/dev/null"
    }
  }
  device {
    name = "aadisable2"
    type = "disk"
    properties = {
      path   = "/dev/zfs"
      source = "/dev/zfs"
    }
  }
  device {
    name = "aadisable3"
    type = "unix-char"
    properties = {
      path   = "/dev/kmsg"
      source = "/dev/kmsg"
    }
  }
  device {
    name = "aadisable4"
    type = "disk"
    properties = {
      path   = "/sys/fs/bpf"
      source = "/sys/fs/bpf"
    }
  }
  device {
    name = "aadisable5"
    type = "disk"
    properties = {
      path   = "/proc/sys/net/netfilter/nf_conntrack_max"
      source = "/proc/sys/net/netfilter/nf_conntrack_max"
    }
  }
}

# Create worker container profile
resource "lxd_profile" "worker_config" {
  name        = "kubernetes_worker_config"
  description = "Kubernetes LXC worker container"

  config = {
    "limits.cpu"           = 2
    "limits.memory"        = "2046MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
//     "security.privileged"  = 1
//     "security.nesting"     = 1
//     "boot.autostart"       = 1
//     "linux.kernel_modules" = "ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter"
//     "raw.lxc"              = <<EOF
// lxc.apparmor.profile=unconfined
// lxc.mount.auto=proc:rw sys:rw cgroup:rw
// lxc.cgroup.devices.allow=a
// lxc.cap.drop=
// EOF
  }

  // device {
  //   name = "aadisable"
  //   type = "disk"
  //   properties = {
  //     path   = "/sys/module/nf_conntrack/parameters/hashsize"
  //     source = "/sys/module/nf_conntrack/parameters/hashsize"
  //   }
  // }
  // device {
  //   name = "aadisable1"
  //   type = "disk"
  //   properties = {
  //     path   = "/sys/module/apparmor/parameters/enabled"
  //     source = "/dev/null"
  //   }
  // }
  // device {
  //   name = "aadisable2"
  //   type = "disk"
  //   properties = {
  //     path   = "/dev/zfs"
  //     source = "/dev/zfs"
  //   }
  // }
  // device {
  //   name = "aadisable3"
  //   type = "unix-char"
  //   properties = {
  //     path   = "/dev/kmsg"
  //     source = "/dev/kmsg"
  //   }
  // }
  // device {
  //   name = "aadisable4"
  //   type = "disk"
  //   properties = {
  //     path   = "/sys/fs/bpf"
  //     source = "/sys/fs/bpf"
  //   }
  // }
  // device {
  //   name = "aadisable5"
  //   type = "disk"
  //   properties = {
  //     path   = "/proc/sys/net/netfilter/nf_conntrack_max"
  //     source = "/proc/sys/net/netfilter/nf_conntrack_max"
  //   }
  // }
}

# # Create storage pool
# resource "lxd_storage_pool" "runner" {
#   name   = "runner"
#   driver = "btrfs"
#   config = {
#     # source = "/var/lib/lxd/disks/runner.img"
#     source = "/var/snap/lxd/common/lxd/disks/runner.img"
#     size   = "30GB"
#   }
# }

# # Create storage volumes
# resource "lxd_volume" "runner" {
#   for_each = toset(local.gitlab_runner_names.runner)
#   name     = each.key
#   pool     = "${lxd_storage_pool.runner.name}"
# }

# Create LXD kubernetes containers
resource "lxd_container" "kubernetes" {
  for_each   = toset(local.kubernetes_names.kubernetes-master)
  name       = each.key
  # Using a cloud-based image will allow cloud-init configuration (ubuntu images just work)
  image      = "ubuntu:22.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.config.name]

  // config = {
  //   "security.privileged"  = 1
  //   "security.nesting"     = 1
  //   "linux.kernel_modules" = "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay"
  //   "raw.lxc"              = "lxc.apparmor.profile = unconfined"
  // }

  # device {
  #   name = "volume1"
  #   type = "disk"
  #   properties = {
  #     path   = "/var/lib/docker"
  #     source = "${lxd_volume.runner[each.key].name}"
  #     pool   = "${lxd_storage_pool.runner.name}"
  #   }
  # }
}

# Create LXD kubernetes worker containers
resource "lxd_container" "kubernetes_workers" {
  for_each   = toset(local.kubernetes_names.kubernetes-worker)
  name       = each.key
  # Using a cloud-based image will allow cloud-init configuration (ubuntu images just work)
  image      = "ubuntu:22.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.config.name]

  config = {
    "limits.cpu"           = 2
    "limits.memory"        = "2046MB"
  //   "security.privileged"  = 1
  //   "security.nesting"     = 1
  //   "linux.kernel_modules" = "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay"
  //   "raw.lxc"              = "lxc.apparmor.profile = unconfined"
  }

  # device {
  #   name = "volume1"
  #   type = "disk"
  #   properties = {
  #     path   = "/var/lib/docker"
  #     source = "${lxd_volume.runner[each.key].name}"
  #     pool   = "${lxd_storage_pool.runner.name}"
  #   }
  # }
}
