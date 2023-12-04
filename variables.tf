variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "consul_chart_version" {
  type        = string
  description = "The Consul Helm chart version to use"
  default     = "1.3.0"
}

variable "consul_version" {
  type        = string
  description = "The Consul version to use"
  default     = "1.17.0"
}
