
# Infra Setup

You can use kind to create a cluster or user docker to enable it.

```sh
# Check version (currently using 1.25)
kind version

# Create cluster
kind create cluster



helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0 --set installCRDs=true --set prometheus.enabled=false --set webhook.timeoutSeconds=4

```


# Deployment

```sh
# 
.\k8s_destroy.ps1 -env "local" -includeDapr "true"
```

## Setup dapr in kubernetes

```sh
dapr init -k
```

## Setup Redis

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis --set image.tag=6.2

# get dynamically genrated password
kubectl get secret --namespace default redis -o jsonpath="{.data.redis-password}" | base64 -d

# || OR

# if redis/charts folder not there one time activity
kubectl kustomize .\deploy\k8s\infra\base\redis\charts\redis\ --enable-helm

#change the values.yaml passwrord:password@1

helm install redis .\deploy\k8s\infra\base\redis\charts\redis\ 
#redis password for all / dapr components : password@1
#redis url for all / dapr components : redis-master.default.svc.cluster.local:6379

helm uninstall redis



### working with redis :



rdcli -h <host>(localhost) -a  -p 6379

redis-cli -p 6379 

MSET orderId1 "101||1" orderId2 "102||1"

```
Using the [Redis CLI](https://redis.com/blog/get-redis-cli-without-installing-redis-server/), connect to the Redis instance:

## Create a namespace (evolution)

```sh
kubectl create ns evolution

kubectl create ns monitoring
```


## Setup Secrets
```sh

#Setup Mssql server password to be used 
kubectl create secret generic mssql --from-literal=SA_PASSWORD="password@1" -n evolution

#AWS S3 Access for app to use
kubectl create secret generic access --from-literal=AWS_ACCESS_KEY="AKIAYVIT7U44J******" -n evolution

kubectl create secret generic secret --from-literal=AWS_SECRET_KEY="Ib1GuABmPxOtDIEfeb7*****************" -n evolution

```
# Continuous Delivery

You can deploy and use `Argo CD` or `Flux` for Continuous Delivery


## Setup Argo CD to deploy.

```sh
kubectl create namespace argocd

#intall from local folder
kubectl apply -n argocd -f deploy/k8s/argo/install.yaml

#Argo UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

#Get Password for Argo
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

```
## Setup Project to Run using Argo CD

```sh
# login to you cluster beore any command, username : admin
argocd login localhost:8080

argocd proj get evolution -o yaml

#Create Project
argocd proj create evolution -d https://kubernetes.default.svc,evolution -s https://github.com/cloud-first-approach/Evolution.infra.git
argocd proj delete evolution

argocd proj allow-cluster-resource evolution * *
argocd proj add-destination evolution https://kubernetes.default.svc,evolution
#Add Identity Service
argocd proj add-source evolution https://github.com/cloud-first-approach/Evolution.Identity.git

#Add more source repo for each services
argocd proj add-source evolution https://github.com/cloud-first-approach/Evolution.Uploader.git

#Add more source repo
argocd proj add-source evolution https://github.com/cloud-first-approach/Evolution.Processor.git

#incase of removal
argocd proj remove-source <PROJECT> <REPO>

```

## Setup Flux

```sh

kubectl create ns flux-system

SET GITHUB_USER=cloud-first-approach

flux bootstrap github --owner=%GITHUB_USER% --repository=Evolution.infra --branch=main --path=./deploy/k8s/flux/clusters/dev --personal
# with access Token required from github

flux reconcile kustomization webapp-dev --with-source

```


# Evolution.infra

Manual instalation

```sh
# dev-infra
kubectl apply -k deploy/k8s/infra/overlays/dev

# prod-infra
kubectl apply -k deploy/k8s/infra/overlays/prod

```
Delpoy using Argo cd

```sh
# Start Dev Environment and sync
argocd app create evo-dev-infra --repo https://github.com/cloud-first-approach/Evolution.infra.git --path deploy/k8s/infra/overlays/dev --dest-server https://kubernetes.default.svc --dest-namespace evolution
#now sync
argocd app sync evo-dev-infra
#delete
argocd app delete evo-dev-infra

# Start Prod Environment and sync
argocd app create evo-prod-infra --repo https://github.com/cloud-first-approach/Evolution.infra.git --path deploy/k8s/infra/overlays/prod --dest-server https://kubernetes.default.svc --dest-namespace evolution

argocd app sync evo-prod-infra

```
# Evolution.Identity

```sh
#Manual instalation

# Includes dapr annotations
kubectl apply -k Evolution.Identity/deploy/k8s/identity/overlays/dev

#ArgoCD

argocd app create evo-identity-app --repo https://github.com/cloud-first-approach/Evolution.Identity.git --path deploy/k8s/identity/overlays/dev --dest-server https://kubernetes.default.svc --dest-namespace evolution

argocd app sync evo-identity-app

```

# Evolution.Uploader

```sh
#Manual instalation

kubectl apply -k deploy/k8s/services

#ArgoCD
argocd app create evo-uploader-app --repo https://github.com/cloud-first-approach/Evolution.Uploader.git --path deploy/k8s/services --dest-server https://kubernetes.default.svc --dest-namespace evolution

argocd app sync evo-uploader-app

```

# Evolution.Processor

```sh
#Manual instalation

kubectl apply -k deploy/k8s/services

#ArgoCD
argocd app create evo-processor-app --repo https://github.com/cloud-first-approach/Evolution.Uploader.git --path deploy/k8s/services --dest-server https://kubernetes.default.svc --dest-namespace evolution

argocd app sync evo-processor-app
```

---

# flagger

```sh

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --set controller.metrics.enabled=true --set controller.podAnnotations."prometheus\.io/scrape"=true --set controller.podAnnotations."prometheus\.io/port"=10254


helm upgrade -i flagger flagger/flagger --namespace ingress-nginx --set prometheus.install=true --set meshProvider=nginx

```
