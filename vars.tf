variable "default_machine_type" {
  default = "n1-highmem-2"
}

variable "region" {
  default = "europe-west2"
}

variable "zone" {
  default = "europe-west2-a"
}

variable "environment" {
  description = "the environment that you are targetting"
}
variable "default_user_name" {}
variable "projectname" {}
