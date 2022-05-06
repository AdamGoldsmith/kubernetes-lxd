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

# Create kubernetes master profile
resource "lxd_profile" "master_config" {
  name        = "kubernetes_master_config"
  description = "Kubernetes master LXC container"

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

# Create storage pool
resource "lxd_storage_pool" "kubernetes" {
  name   = "kubernetes-master"
  driver = "dir"
  config = {
    source = "/var/snap/lxd/common/lxd/storage-pools/kubernetes-master"
  }
}

# Create storage volumes
resource "lxd_volume" "kubernetes" {
  for_each = toset(local.instance_names.kubernetes-master)
  name     = each.key
  pool     = "${lxd_storage_pool.kubernetes.name}"
}

# Create kubernetes master containers
resource "lxd_container" "kubernetes_masters" {
  for_each   = toset(local.instance_names.kubernetes-master)
  name       = each.key
  image      = "ubuntu:22.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.master_config.name]

  device {
    name = "volume1"
    type = "disk"
    properties = {
      path   = "/var/lib/docker"
      source = "${lxd_volume.kubernetes[each.key].name}"
      pool   = "${lxd_storage_pool.kubernetes.name}"
    }
  }
}
