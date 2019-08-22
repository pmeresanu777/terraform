variable "project" {default = "demos-esd-automation"}
variable "region" {default = "us-east1"}
variable "subnetwork" {default = "default"}
variable "image" {default = "centos-7-v20190813"}
variable "infrastructure_name" {default = "dev"}
variable "credentials" {}
variable "zone" {default = "us-east1-c"}
variable "cda_server" {default = "https://cda.automic-demo.com/bond/"}
variable "cda_user" {default = "100/ARA/ARA"}
variable "cda_password" {}


variable "num_nodes" {
  description = "Number of nodes to create"
  default     = 1
}

locals {
	id = "${random_integer.name_extension.result}"
}

resource "random_integer" "name_extension" {
  min     = 1
  max     = 99999
}

provider "google" {
  credentials = "${var.credentials}"
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_compute_instance" "default" {
  count        = "${var.num_nodes}"
  project      = "${var.project}"
  zone         = "us-east1-c"
  name         = "${var.infrastructure_name}-${count.index + 1}-${local.id}"
  machine_type = "f1-micro"
  
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  
  network_interface {
    subnetwork = "${var.subnetwork}"
    subnetwork_project = "${var.project}"
  }
 provisioner "remote-exec" {
	inline = [
		"mkdir -p ${var.remote_working_dir}",
		"mkdir -p ${var.remote_working_dir}/scripts"
	]

	connection {
		type        = "ssh"
		user        = "automic"
		private_key = "${file("${var.private_key_file}")}"
		password    = "${var.ubuntu_password}"
	}
  }

  provisioner "file" {
	source      = "artifacts"
	destination = "${var.remote_working_dir}"

	connection {
		type        = "ssh"
		user        = "automic"
		private_key = "${file("${var.private_key_file}")}"
		password    = "${var.ubuntu_password}"
	}
  }

  provisioner "file" {
	source      = "scripts/remote/agent_sm_installation.sh"
	destination = "${var.remote_working_dir}/scripts/agent_sm_installation.sh"

	connection {
		type        = "ssh"
		user        = "automic"
		private_key = "${file("${var.private_key_file}")}"
		password    = "${var.ubuntu_password}"
	}
  }	
	
}
