variable "kubernetes_counts" {
  type    = map(number)
  default = {
    "kubernetes-master" = 1  # Key name is used for resource prefix
    "kubernetes-worker" = 2  # Key name is used for resource prefix
  }
}
