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

variable "cloudfront_aliases" {
  description = "Name of the cloudfront aliases"
  type        = list(string)
}

variable "origins" {
  description = "Map of origins for cloudfront"
  type        = map(any)
}