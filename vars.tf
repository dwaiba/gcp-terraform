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
  description = "The environment that you are targetting- Instance names and disk names are computed based upon environ. name"
}

variable "disk_default_size" {
  description = "The Disk Size in GB to be attached and available at /data as mounted ext4 fs on lvm - recommended 50 or 100"
}

variable "default_user_name" {
  description = "The username with which you intend to perform gcloud compute ssh on success provisioning thus syncing ssh keys"
}

variable "projectname" {}
