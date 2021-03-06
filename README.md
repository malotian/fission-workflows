# prerequisite 

[awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)

[kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

[helm](https://helm.sh/docs/using_helm/#installing-helm)

# build docker image with all prerequisites 
	cd docker
	docker-compose build

# create/update aws config 
	cp aws.env.sample aws.env
	# edit/update values for AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, AWS_DEFAULT_OUTPUT

# run docker image with all prerequisites 
	docker run --env-file=aws.env -it malotian/k8-tools /bin/bash

# create kubernetes cluster (skip if you already have)

    eksctl create cluster --name fission-dev-us-east-1 --version 1.14 --node-private-networking --region=us-east-1 --zones=us-east-1a,us-east-1b,us-east-1d
    
# create/update kube config

    aws eks --region us-east-1 update-kubeconfig --name fission-us-east-1

## install fission

    kubectl create namespace fission
	kubectl -n fission apply -f https://github.com/fission/fission/releases/download/1.6.0/fission-all-1.6.0.yaml

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




