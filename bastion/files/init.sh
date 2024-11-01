#!/bin/bash

set -ux

: ${TERRAFORM_VERSION}
: ${HELM_VERSION}
: ${KUBECTL_VERSION}

install_helm(){
  curl -fSsL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" -o /tmp/helm.tar.gz
  tar -xvf /tmp/helm.tar.gz --strip-components=1 -C /usr/bin/ 'linux-amd64/helm'
  chmod +x /usr/bin/helm
  rm -f /tmp/helm.tar.gz
}

install_terraform(){
  curl -fSsL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    -o /tmp/terraform.zip
  unzip -o /tmp/terraform.zip -d /usr/bin/
  chmod +x /usr/bin/terraform
  rm -f /tmp/terraform.zip
}

install_kubectl(){
  curl -fSsL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/bin/kubectl
  chmod +x /usr/bin/kubectl
}

# Install required OS packages
dnf -y install \
  ansible \
  awscli-2 \
  ec2-instance-connect \
  git \
  postgresql15 \
  python3-pip \
  unzip \
  vim \
  zip \
  postgresql-client	
  
while [ ! -x /usr/bin/terraform ]; do
  install_terraform
done

while [ ! -x /usr/bin/kubectl ]; do
  install_kubectl
done

while [ ! -x /usr/bin/helm ]; do
  install_helm
done
