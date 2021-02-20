
terraform {
    backend "s3" {
        bucket="aenglema-terraform"
        key="terraform/dev/helm/terraform.tfstate"
        region="us-east-1"
    }
    required_providers {
        helm = {
        source = "hashicorp/helm"
        version = "1.3.2"
        }
    }
    required_version = ">= 0.13"
}

provider "helm" {
  kubernetes {
    config_path = "kubectl.conf"
  }
}

resource "helm_release" "redis" {
  name       = "my-release"
  chart      = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  set {
    name  = "password"
    value = "978!@Shlyn"
  }
  set {
    name = "global.storageClass"
    value = "managed-nfs-storage"
  }
  set {
    name = "master.service.type"
    value = "LoadBalancer"
  }
  set {
    name = "master.service.loadBalancerIP"
    value = "192.168.1.122"
  }
  set {
    name = "slave.service.type"
    value = "LoadBalancer"
  }
  set {
    name = "slave.service.loadBalancerIP"
    value = "192.168.1.123"
  }

}
resource "helm_release" "cds-redis" {
  name       = "cds-redis"
  chart      = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  set {
    name  = "password"
    value = "0Q8JQ60O1Nk2"
  }
  set {
    name = "global.storageClass"
    value = "managed-nfs-storage"
  }
  set {
    name = "master.service.type"
    value = "LoadBalancer"
  }
  set {
    name = "master.service.loadBalancerIP"
    value = "192.168.1.124"
  }
  set {
    name = "slave.service.type"
    value = "LoadBalancer"
  }
  set {
    name = "slave.service.loadBalancerIP"
    value = "192.168.1.125"
  }

}
