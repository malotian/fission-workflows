#!/bin/sh

set -e
apt-get update
apt-get -y install curl openssl python-pip zip vim

curl -L "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

curl -L https://github.com/fission/fission/releases/download/1.5.0/fission-cli-linux -o /usr/local/bin/fission
chmod +x /usr/local/bin/fission

curl -sLSf https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

# aws-iam-authenticator
# https://github.com/kubernetes-sigs/aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
aws-iam-authenticator help

# awscli
pip install awscli
aws --version

# install YAML tools
pip install yamllint yq

