variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "repository_name" {
  description = "Name of the container registry"
  type        = string
  default     = ""
}
