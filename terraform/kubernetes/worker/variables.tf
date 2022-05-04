variable "instance_counts" {
  type    = map(number)
  default = {
    "kubernetes-worker" = 2  # Key name is used for resource prefix
  }
}
