variable "default_machine_type" {
  default = "n1-highmem-2"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "environment" {
  description = "the environment that you are targetting"
}
variable "default_user_name" {}
variable "projectname" {}
