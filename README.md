eksctl create cluster --name fission-eks --version 1.14 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4 --node-ami auto
aws eks --region us-east-1 update-kubeconfig --name fission-eks
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
curl -sLSf https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo bash
helm init --skip-refresh --upgrade --service-account tiller
helm install --name fission --namespace fission https://github.com/fission/fission/releases/download/1.5.0/fission-all-1.5.0.tgz\n
fission env create --name nodejs --image fission/node-env
fission function create --name hello --env nodejs --code hello.js
fission function test --name hello

helm repo add fission-charts https://fission.github.io/fission-charts/
helm repo update
helm install --wait -n fission-workflows fission-charts/fission-workflows --version 0.6.0

export FISSION_ROUTER=$(kubectl --namespace fission get svc router -o=jsonpath='{..hostname}')
echo $FISSION_ROUTER
export FISSION_NAMESPACE=fission

fission function delete --name hello
fission function create --name hello --env nodejs --code hello.js

fission function delete --name name
fission function create --name name --env nodejs --code hello.js

fission function create --name helloname --env workflow --src helloname.wf.yaml

fission route create --method GET --url /helloname --function helloname
curl http://$FISSION_ROUTER/fission-function/helloname
