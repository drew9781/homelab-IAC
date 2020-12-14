
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
    value = "978!@Shln"
  }

}