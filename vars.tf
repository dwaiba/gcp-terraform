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

variable "default_user_name" {
  description = "The username with which you intend to perform gcloud compute ssh on success provisioning thus syncing ssh keys"
}

variable "projectname" {}
