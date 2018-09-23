provider "google" {
  credentials = "${file("credentials/google.json")}"
  project     = "${var.projectname}"
  region      = "${var.region}"
}
