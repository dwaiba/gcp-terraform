provider "google" {
  version     = "3.11.0"
  credentials = file("credentials/google.json")
  project     = var.projectname
  region      = var.region
}
terraform {
  required_providers {
    google = "~> 3.11.0"
  }
}
