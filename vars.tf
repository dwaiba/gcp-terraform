variable "default_machine_type" {
  default = "n1-highmem-2"
}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-a"
}

variable "environment" {
  description = "The environment that you are targetting- Instance names and disk names are computed based upon environ. name"
}
variable "count_vms" {
  description = "The number of CentOS VMs to create in GCP- Each would have the same set of tools with same size individual disk sizes mounted and ext4 fs available in /data"
}

variable "disk_default_size" {
  description = "The Disk Size in GB to be attached to each instance and available at /data as mounted ext4 fs on lvm - recommended 50 or 100"
}

variable "default_user_name" {
  description = "The username with which you intend to perform gcloud compute ssh on success provisioning thus syncing ssh keys"
}
/**
variable "number_instances_with_disks"
{
  description = "Number of instances each with disks attached wanted - 1, 2, 4 or ..."
}
**/
variable "projectname" {}