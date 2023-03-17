variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "app"
}

variable "image_tag" {
  type        = string
  description = "Source image tag"
  default     = "latest"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    "Env"      = "Dev"
    "Provider" = "FARGATE"
  }
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "app-cluster"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  default = 3
}

variable "cidr_blocks" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24"
  ]
}
