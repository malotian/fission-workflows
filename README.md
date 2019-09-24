
# prerequisite 

[awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)

[kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

# configure aws 
    aws configure

# create kubernetes cluster (skip if you already have)

    eksctl create cluster --name fission-eks --version 1.14 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4 --node-ami auto

# create/update kube config

    aws eks --region us-east-1 update-kubeconfig --name fission-eks

# create tiller account

    kubectl --namespace kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

# install helm

    curl -sLSf https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo bash
    helm init --skip-refresh --upgrade --service-account tiller

## install fission

    helm install --name fission --namespace fission https://github.com/fission/fission/releases/download/1.5.0/fission-all-1.5.0.tgz

## install fission workflows

    helm repo add fission-charts https://fission.github.io/fission-charts/
    helm repo update
    helm install --wait -n fission-workflows fission-charts/fission-workflows --version 0.6.0

## set environment

    export FISSION_ROUTER=$(kubectl --namespace fission get svc router -o=jsonpath='{..hostname}')
    export FISSION_NAMESPACE=fission

# checkout test fission - function & workflows

    git clone https://github.com/malotian/fission-workflows.git && cd fission-workflows

#  setup & test fission - function

## install fission cli

    curl -Lo fission https://github.com/fission/fission/releases/download/1.5.0/fission-cli-linux && chmod +x fission && sudo mv fission /usr/local/bin/

## create fission environment

    fission env create --name nodejs --image fission/node-env

## create fission function hello-world

    fission function create --name hello-world --env nodejs --code hello-world.js

## invoke fission function hello-world

    fission function test --name hello-world

#  setup & test fission - workflows
## create fission function hello

    fission function create --name hello --env nodejs --code hello.js

## create fission function name

    fission function create --name name --env nodejs --code name.js

## create fission workflows

    fission function create --name hello-name --env workflow --src hello-name.wf.yaml

## create fission workflows route

    fission route create --method GET --url /hello-name --function hello-name

## invoke fission workflow hello-name

    curl http://$FISSION_ROUTER/fission-function/hello-name

#  clean  test fission - function & workflows

    fission function delete --name hello-world
    fission function delete --name hello
    fission function delete --name name
    fission function delete --name hello-name
    fission route list|grep hello-name |cut -f1 -d' '|xargs -n1 fission route delete --name
    fission env delete --name nodejs
    helm del --purge fission-workflows


