variable "cda_server" {default = "https://cda.automic-demo.com/bond/"}
variable "cda_user" {default = "100/ARA/ARA"}
variable "cda_password" {}

# Configure the CDA
provider "cda" {
  cda_server   = "${var.cda_server}"
  user         = "${var.cda_user}"
  password     = "${var.cda_password}"  
}

# Add a Environment
resource "cda_environment" "firstEnvironment" {
  name  = "PaulsEnv"
  folder= "TIXCHANGE"
  type  = "Generic"
  dynamic_properties = {}
  custom_properties = {}
  deployment_targets = []
  description = "Test Environment"
  owner = "100/ARA/ARA"  
}

