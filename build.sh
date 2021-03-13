mkdir tmp
cp DockerFile.core tmp/Dockerfile
cp inventory/core/core.tf tmp/
cp secrets/proxmox.tfvars tmp/
cp secrets/ansible_postgres.yml tmp/
cp secrets/ansible-cds.yml tmp/
cp -r ansible tmp/
cd tmp
if ! docker build . -t drew9781/iac-core:1.1 --no-cache; then
    exit 1
fi
cd .. && rm -rf tmp

mkdir tmp
cp DockerFile.k8s tmp/Dockerfile
cp inventory/k8s/k8s.tf tmp/
cp secrets/proxmox.tfvars tmp/
cp -r ansible tmp/
cd tmp
if ! docker build . -t drew9781/iac-k8s:1.1; then
    exit 1
fi
cd .. && rm -rf tmp

mkdir tmp
cp DockerFile.helm tmp/Dockerfile
cp inventory/helm/helm.tf tmp/
cp secrets/kubectl.conf tmp/
cd tmp
if ! docker build . -t drew9781/iac-helm:1.1; then
    exit 1
fi
cd .. && rm -rf tmp
