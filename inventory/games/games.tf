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
    key="terraform/dev/games/terraform.tfstate"
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


resource "proxmox_vm_qemu" "dst" {
    name = "dst.internal.aenglema.com"
    desc = ""
    target_node = "pve"

    clone = "${var.clone_id}"
    cores = 2
    sockets = 1
    memory = 4860

    disk {
        id = 0
        type = "scsi"
        size = 12
        storage = "FreenasImages"
    }
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A2"
        queues = 0
        rate = 0
        tag = 0
    }

    ssh_user        = "${var.ssh_user}"
    ssh_private_key = "${var.ssh_private}"

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.25/24,gw=192.168.1.1"
    nameserver = "192.168.1.11"

    ciuser     = "${var.ci_user}"
    cipassword = "${var.ci_pass}"
    sshkeys = "${var.ssh_public}"

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.25"
        type = "ssh"
        user = "${var.ci_user}"
        private_key = "${file("~/.ssh/id_rsa")}"
    }

}

resource "proxmox_vm_qemu" "ark" {
    name = "ark.internal.aenglema.com"
    desc = ""
    target_node = "pve"

    clone = "${var.clone_id}"
    cores = 2
    sockets = 1
    memory = 4860

    disk {
        id = 0
        type = "scsi"
        size = 12
        storage = "FreenasImages"
    }
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A2"
        queues = 0
        rate = 0
        tag = 0
    }

    ssh_user        = "${var.ssh_user}"
    ssh_private_key = "${var.ssh_private}"

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.26/24,gw=192.168.1.1"
    nameserver = "192.168.1.11"

    ciuser     = "${var.ci_user}"
    cipassword = "${var.ci_pass}"
    sshkeys = "${var.ssh_public}"

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.26"
        type = "ssh"
        user = "${var.ci_user}"
        private_key = "${file("~/.ssh/id_rsa")}"
    }

}