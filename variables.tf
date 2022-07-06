variable "cloud_api_key" {
  type = string
}

variable "cloud_api_secret" {
  type = string
}

variable "tag_name" {
  type    = string
  default = "test"
}

variable "default_region" {
  type    = string
  default = "us-west1"
}
