variable "pm_api_url" { type = string }
variable "pm_password"{ type = string }
variable "pm_user"{ type = string}
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
    key="terraform/dev/core/terraform.tfstate"
    region="us-east-1"
  }
    required_providers {
      proxmox = {
       source  = "Telmate/proxmox"
        version = "2.6.4"
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
    pm_api_url  =  var.pm_api_url
    pm_password =  var.pm_password
    pm_user     =  var.pm_user

}

provider "icinga2" {
  api_url                  = "https://icinga.internal.aenglema.com:5665/v1"
  api_user                 = "admin"
  api_password             = var.icinga_api_password
  insecure_skip_tls_verify = true
}

provider "dns" {
  update {
    server        = "192.168.1.12"
    key_name      = "aenglema."
    key_algorithm = "hmac-md5"
    key_secret    = var.dns_key_secret
  }
}


resource "proxmox_vm_qemu" "DNSmaster" {
    
    name         = "DNSmaster"
    desc         = "tf description"
    target_node  = "pve"

    cores        = 2
    sockets      = 1
    memory       = 2024
    ipconfig0    = "ip=192.168.1.11/24,gw=192.168.1.1"
    nameserver   = "192.168.1.11 8.8.8.8"
    scsihw       = "virtio-scsi-pci"
    searchdomain = "internal.aenglema.com"
    bootdisk     = "scsi0"
}

resource "icinga2_host" "DNSmaster" {
  hostname      = "DNSmaster"
  address       = "192.168.1.11"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "DNSmaster"{
    zone = "internal.aenglema.com."
    name = "DNSmaster"
    addresses = ["192.168.1.11"]
    ttl = 300
}


resource "proxmox_vm_qemu" "ns01" {
    name = "ns01.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = var.clone_id
    cores = 2
    sockets = 1
    memory = 2560

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"

    disk {
        type = "virtio"
        size = "12G"
        storage = var.vm_storage_location
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A4"
        queues = 0
        rate = 0
        tag = -1
    }

    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.12/24,gw=192.168.1.1"
    nameserver = "192.168.1.11"

    ciuser     = var.ci_user
    cipassword = "**********"
    sshkeys    = var.ssh_public

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.12"
        type = "ssh"
        user = var.ci_user
        private_key = var.ssh_private
    }

}

resource "proxmox_vm_qemu" "icinga" {
    name = "icinga.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = var.clone_id
    cores = 2
    sockets = 1
    memory = 4800

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        type = "virtio"
        size = "12G"
        storage = var.vm_storage_location
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A6"
        queues = 0
        rate = 0
        tag = -1
    }

    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.14/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = var.ci_user
    # cipassword = var.ci_pass
    sshkeys    = var.ssh_public

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.14"
        type = "ssh"
        user = var.ci_user
        private_key = var.ssh_private
    }

}

resource "proxmox_vm_qemu" "postgres-master" {
    name = "postgres-master.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = var.clone_id
    cores = 6
    sockets = 1
    memory = 8192

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        type = "virtio"
        size = "12G"
        storage = var.vm_storage_location
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A8"
        tag = -1
    }

    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.65/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = var.ci_user
    cipassword = var.ci_pass
    sshkeys    = var.ssh_public

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.65"
        type = "ssh"
        user = var.ci_user
        private_key = var.ssh_private
    }

}

resource "icinga2_host" "postgres-master" {
  hostname      = "postgres-master"
  address       = "192.168.1.65"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "postgres-master"{
    zone = "internal.aenglema.com."
    name = "postgres-master"
    addresses = ["192.168.1.65"]
    ttl = 300
}
resource "proxmox_vm_qemu" "ipa" {
    name = "ipa.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = var.clone_id
    cores = 2
    sockets = 1
    memory = 2560

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        type = "virtio"
        size = "12G"
        storage = var.vm_storage_location
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
        macaddr = "C2:87:CA:1A:63:A8"
        tag = -1
    }

    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.66/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = var.ci_user
    cipassword = var.ci_pass
    sshkeys    = var.ssh_public

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.66"
        type = "ssh"
        user = var.ci_user
        private_key = var.ssh_private
    }

}

resource "icinga2_host" "ipa" {
  hostname      = "ipa"
  address       = "192.168.1.66"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "ipa"{
    zone = "internal.aenglema.com."
    name = "ipa"
    addresses = ["192.168.1.66"]
    ttl = 300
}

resource "proxmox_vm_qemu" "cds" {
    name = "cds.internal.aenglema.com"
    desc = "Debian 10 x86_64 template built with packer (). Username: aenglema"
    target_node = "pve"

    clone = var.clone_id
    cores = 4
    sockets = 1
    memory = 4800

    scsihw          = "virtio-scsi-pci"
    bootdisk        = "scsi0"


    disk {
        type = "virtio"
        size = "12G"
        storage = var.vm_storage_location
    }
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.70/24,gw=192.168.1.1"
    nameserver = "192.168.1.12"

    ciuser     = var.ci_user
    cipassword = var.ci_pass
    sshkeys    = var.ssh_public

    //post run commands
    provisioner "remote-exec" {
        inline = [
        "ip a"
        ]
    }
    connection {
        host = "192.168.1.70"
        type = "ssh"
        user = var.ci_user
        private_key = var.ssh_private
    }

}

resource "icinga2_host" "cds" {
  hostname      = "cds"
  address       = "192.168.1.70"
  check_command = "hostalive"
  templates     = ["generic-host-production"]

  vars = {
    os        = "Linux"
  }
}

resource "dns_a_record_set" "cds"{
    zone = "internal.aenglema.com."
    name = "cds"
    addresses = ["192.168.1.70"]
    ttl = 300
}


# resource "proxmox_vm_qemu" "jira" {
#     name = "jira.aenglema.com"
#     desc = ""
#     target_node = "pve"

#     clone = var.clone_id
#     cores = 2
#     sockets = 1
#     memory = 2560

#     disk {
#         id = 0
#         type = "scsi"
#         size = "12G"
#         storage = var.vm_storage_location
#     }
#     network {
#         id = 0
#         model = "virtio"
#         bridge = "vmbr0"
#         macaddr = "C2:87:CA:1A:63:A2"
#         queues = 0
#         rate = 0
#         tag = 0
#     }

#     ssh_user        = var.ssh_user
#     ssh_private_key = var.ssh_private

#     os_type = "cloud-init"
#     ipconfig0 = "ip=192.168.1.16/24,gw=192.168.1.1"
#     nameserver = "192.168.1.11"

#     ciuser     = var.ci_user
#     cipassword = var.ci_pass
#     sshkeys = var.ssh_public

#     //post run commands
#     provisioner "remote-exec" {
#         inline = [
#         "ip a"
#         ]
#     }
#     connection {
#         host = "192.168.1.16"
#         type = "ssh"
#         user = var.ci_user
#         private_key = file("~/.ssh/id_rsa")
#     }

# }