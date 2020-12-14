variable "pm_api_url" { type = "string" }
variable "pm_password"{ type = "string" }
variable "pm_user"{ type = "string"}
variable "clone_id"{}
variable "vm_storage_location"{default = "local"}
variable "ci_user"{}
variable "ci_pass"{}
variable "ssh_public"{}
variable "ssh_private" {}
variable "ssh_user" {}


terraform {
  backend "s3" {
    bucket="aenglema-terraform"
    key="terraform/dev/automation/terraform.tfstate"
    region="us-east-1"
  }
}
provider "proxmox"{
  pm_tls_insecure = true
  
    // Credentials here or environment
    pm_api_url  =  "${var.pm_api_url}"
    pm_password =  "${var.pm_password}"
    pm_user     =  "${var.pm_user}"

}

resource "proxmox_vm_qemu" "airflow" {
    name = "airflow.internal.aenglema.com"
    desc = "tf description"
    target_node = "pve2"

    cores = 2
    sockets = 1
    memory = 2560

    ipconfig0 = "ip=192.168.1.23/24,gw=192.168.1.1"
}


