variable "instance_counts" {
  type    = map(number)
  default = {
    "kubernetes-master" = 1  # Key name is used for resource prefix
  }
}
