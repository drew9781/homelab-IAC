variable "dns_key_secret" {}
 // https://sort.veritas.com/public/documents/via/7.0/linux/productguides/html/vcs_bundled_agents/ch03s06s06s06.htm
provider "dns" {
  update {
    server        = "192.168.1.12"
    key_name      = "aenglema."
    key_algorithm = "hmac-md5"
    key_secret    = "${var.dns_key_secret}"
  }
}

terraform {
  backend "s3" {
    bucket="aenglema-terraform"
    key="terraform/dev/dns/terraform.tfstate"
    region="us-east-1"
  }
}

resource "dns_a_record_set" "gitlab"{
    zone = "internal.aenglema.com."
    name = "gitlab"
    addresses = ["192.168.1.6"]
    ttl = 300
}

resource "dns_a_record_set" "jira"{
    zone = "internal.aenglema.com."
    name = "jira"
    addresses = ["192.168.1.16"]
    ttl = 300
}

resource "dns_a_record_set" "pve"{
    zone = "internal.aenglema.com."
    name = "pve"
    addresses = ["192.168.1.33"]
    ttl = 300
}
resource "dns_a_record_set" "airflow"{
    zone = "internal.aenglema.com."
    name = "airflow"
    addresses = ["192.168.1.23"]
    ttl = 300
}

resource "dns_a_record_set" "icinga"{
    zone = "internal.aenglema.com."
    name = "icinga"
    addresses = ["192.168.1.14"]
    ttl = 300
}

resource "dns_a_record_set" "ark"{
    zone = "internal.aenglema.com."
    name = "ark"
    addresses = ["192.168.1.26"]
    ttl = 300
}

resource "dns_a_record_set" "dst"{
    zone = "internal.aenglema.com."
    name = "dst"
    addresses = ["192.168.1.25"]
    ttl = 300
}
