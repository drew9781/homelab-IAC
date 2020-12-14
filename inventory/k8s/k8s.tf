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
variable "dns_key_secret" {}
variable "icinga_api_password" {}



terraform {
  backend "s3" {
    bucket="aenglema-terraform"
    key="terraform/dev/k8s/terraform.tfstate"
    region="us-east-1"
  }
    required_providers {
      proxmox = {
       source  = "terraform.example.com/telmate/proxmox"
        version = ">=1.0.0"
    }
    icinga2 = {
      source = "Icinga/icinga2"
      version = "0.5.0-pre"
    }
  }
  required_version = ">= 0.13"
}

provider "proxmox"{
  pm_tls_insecure = true
  
    // Credentials here or environment
    pm_api_url  =  "${var.pm_api_url}"
    pm_password =  "${var.pm_password}"
    pm_user     =  "${var.pm_user}"

}

provider "icinga2" {
  api_url                  = "https://icinga.internal.aenglema.com:5665/v1"
  api_user                 = "admin"
  api_password             = "${var.icinga_api_password}"
  insecure_skip_tls_verify = true
}

provider "dns" {
  update {
    server        = "192.168.1.12"
    key_name      = "aenglema."
    key_algorithm = "hmac-md5"
    key_secret    = "${var.dns_key_secret}"
  }
}



resource "proxmox_vm_qemu" "k8smaster" {
    name = "k8smaster.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = "${var.clone_id}"
    cores = 2
    sockets = 1
    memory = 4096 

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        id = 0
        type = "virtio"
        size = 12
        storage = "${var.vm_storage_location}"
    }
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A9"
        queues = 0
        rate = 0
        tag = 0
    }

    ssh_user        = "${var.ssh_user}"
    ssh_private_key = "${var.ssh_private}"

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.67/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = "${var.ci_user}"
    cipassword = "**********"
    sshkeys    = "${var.ssh_public}"

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.67"
        type = "ssh"
        user = "${var.ci_user}"
        private_key = "${var.ssh_private}"
    }

}

resource "icinga2_host" "k8smaster" {
  hostname      = "k8smaster"
  address       = "192.168.1.67"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "k8smaster"{
    zone = "internal.aenglema.com."
    name = "k8smaster"
    addresses = ["192.168.1.67"]
    ttl = 300
}

resource "proxmox_vm_qemu" "k8snode1" {
    name = "k8snode1.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve2"

    clone = "${var.clone_id}"
    cores = 2
    sockets = 1
    memory = 4096 

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        id = 0
        type = "virtio"
        size = 12
        storage = "${var.vm_storage_location}"
    }
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:AA"
        queues = 0
        rate = 0
        tag = 0
    }

    ssh_user        = "${var.ssh_user}"
    ssh_private_key = "${var.ssh_private}"

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.68/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = "${var.ci_user}"
    cipassword = "**********"
    sshkeys    = "${var.ssh_public}"

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.68"
        type = "ssh"
        user = "${var.ci_user}"
        private_key = "${var.ssh_private}"
    }

}

resource "icinga2_host" "k8snode1" {
  hostname      = "k8snode1"
  address       = "192.168.1.68"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "k8snode1"{
    zone = "internal.aenglema.com."
    name = "k8snode1"
    addresses = ["192.168.1.68"]
    ttl = 300
}

resource "proxmox_vm_qemu" "k8snode2" {
    name = "k8snode2.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve3"

    clone = "${var.clone_id}"
    cores = 2
    sockets = 1
    memory = 4096 

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        id = 0
        type = "virtio"
        size = 12
        storage = "${var.vm_storage_location}"
    }
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:AB"
        queues = 0
        rate = 0
        tag = 0
    }

    ssh_user        = "${var.ssh_user}"
    ssh_private_key = "${var.ssh_private}"

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.69/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = "${var.ci_user}"
    cipassword = "**********"
    sshkeys    = "${var.ssh_public}"

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.69"
        type = "ssh"
        user = "${var.ci_user}"
        private_key = "${var.ssh_private}"
    }

}

resource "icinga2_host" "k8snode2" {
  hostname      = "k8snode2"
  address       = "192.168.1.69"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "k8snode2"{
    zone = "internal.aenglema.com."
    name = "k8snode2"
    addresses = ["192.168.1.69"]
    ttl = 300
}
