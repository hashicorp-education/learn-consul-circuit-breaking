locals {
  cluster_name = "learn-cbreaking-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}