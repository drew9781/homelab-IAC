# Homelab IaC

## How to unlock secrets
If public GPG key is on the ring, run `git secret reveal`
See git-secret docs for adding GPG keys. Obviously this is for me only.

## How to run
./DockerFile builds the base image used to run terraform on proxmox.
./build.sh builds each container image responsible for a terraform group. 

To run terraform on the core group, run this after building the images:
```
docker run -it --rm drew9781/iac-core:1.1 terraform apply --var-file proxmox.tfvars
```
