packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
variable "client_id" {
  type      = string
  sensitive = true
}
variable "client_secret" {
  type      = string
  sensitive = true
}
variable "subscription_id" {
  type      = string
  sensitive = true
}
variable "tenant_id" {
  type      = string
  sensitive = true
}
variable "resource_group" {
  type = string
}
variable "os_type" {
  type = string
}
variable "image_name" {
  type = string
}
variable "location" {
  type = string
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  location        = "${var.location}"
  os_type         = "${var.os_type}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"
  vm_size         = "Standard_DS2_v2"
  shared_image_gallery {
    subscription   = "${var.subscription_id}"
    resource_group = "${var.resource_group}"
    gallery_name   = "Packer_Image_Gallery"
    image_name     = "packer-ubuntu-22-04-lts-gen2-shared"
    image_version  = "1.0.0"
  }
  shared_image_gallery_destination {
    subscription         = "${var.subscription_id}"
    resource_group       = "${var.resource_group}"
    gallery_name         = "Packer_Image_Gallery"                #compute gallery must exist
    image_name           = "packer-ubuntu-22-04-lts-gen2-shared" #vm definition must exist
    image_version        = "2.0.0"
    replication_regions  = ["eastus", "westus"]
    storage_account_type = "Standard_LRS"
  }
}

build {
  sources = ["source.azure-arm.ubuntu"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["mkdir /custom"]
  }
}