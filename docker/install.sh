#!/bin/sh

# do all in one step
apk update 

set -ex 
apk add --update libstdc++ curl bash ca-certificates git python zip
apk add --update -t deps curl make py-pip openssl

for pkg in glibc-2.28-r0 glibc-bin-2.28-r0;
    do curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/3.28-r0/${pkg}.apk -o /tmp/${pkg}.apk; 
done 

apk add --allow-untrusted /tmp/*.apk && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

curl -L "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

curl -L https://github.com/fission/fission/releases/download/1.5.0/fission-cli-linux -o /usr/local/bin/fission
chmod +x /usr/local/bin/fission

curl -sLSf https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash

# awscli
pip install awscli
aws --version

# install YAML tools
pip install yamllint yq

# cleanup
apk del --purge deps
rm /var/cache/apk/*
rm -rf /tmp/*
