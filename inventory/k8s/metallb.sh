k8s apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
k8s apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
k8s create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"