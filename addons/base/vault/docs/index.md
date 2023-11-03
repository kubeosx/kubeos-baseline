
## Getting started with vault


## Unseal Vault


```bash
 helm install vault hashicorp/vault --namespace=vault-backend --dry-run=client
 
helm install vault vault --repo https://helm.releases.hashicorp.com \
  --namespace=vault-backend \
  --set server.enabled=false \
  --set injector.enabled=true \



kubectl exec vault-0 -n vault-backend -- vault operator init -key-shares=1 -key-threshold=1 -format=json > keys.json

# if name sapce if default
kubectl exec vault-0 -n default -- vault operator init -key-shares=1 -key-threshold=1 -format=json > keys.json

VAULT_UNSEAL_KEY=$(cat keys.json | jq -r ".unseal_keys_b64[]")

VAULT_ROOT_KEY=$(cat keys.json | jq -r ".root_token")

kubectl exec vault-0 -n vault-backend -- vault operator unseal $VAULT_UNSEAL_KEY


kubectl exec vault-0 -it -n vault-backend -- sh 
$ vault login $VAULT_ROOT_KEY

vault secrets enable -version=2 -path="kubeos" kv

vault kv put kubeos/appname name=kubeos
vault kv put kubeos/dev/shopcart-api name=shopcart-api

vault kv put kubeos/dev/vault-test name=shopcart-api
vault kv get kubeos/dev/shopcart-api


vault policy write admin-policy - <<EOH
path "kubeos/dev/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "secrets/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "kubeos/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOH


vault policy list


# Enable Kubernetes auth method

vault auth enable kubernetes


vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Create Service Account 
kubectl create serviceaccount kubeos

# Create Service Account
vault write auth/kubernetes/role/kubeos \
        bound_service_account_names=kubeos \
        bound_service_account_namespaces=default \
        policies=admin-policy \
        ttl=72h


# NOW SERVICE SPECIFIC STUFF

# service specfic policy
vault policy write demo-policy - <<EOH
path "kubeos/dev/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "kubeos/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOH


# Bind Service specific Role to Service Account
vault write auth/kubernetes/role/demo \
        bound_service_account_names=demo \
        bound_service_account_namespaces=dev \
        policies=demo-policy \
        ttl=72h

vault kv put kubeos/dev/demo name=donedonedone2

```

Testing Out Vault

```bash 
# Example POD

---
kubectl apply -f - <<EOH
apiVersion: v1
kind: Pod
metadata:
  name: vault-client
  namespace: default
  annotations:
    vault.hashicorp.com/agent-inject: 'true'
    vault.hashicorp.com/role: kubeos
    vault.hashicorp.com/agent-inject-secret-config.txt: 'kubeos/dev/shopcart-api'
spec:
  containers:
  - image: nginx:latest
    name: nginx
  serviceAccountName: kubeos
EOH

kubectl apply -f pod.yaml


kubectl exec -it vault-client /bin/bash


jwt_token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)


curl --request POST \
    --data '{"jwt": "'$jwt_token'", "role": "kubeos"}' \
    http://10.96.0.1:443/v1/auth/kubernetes/login


    curl -H "X-Vault-Token: s.bSRl7TNajYxWvA7WiLdTQS7Z" \
     -H "X-Vault-Namespace: vault" \
     -X GET http://35.193.55.248:32000/v1/demo-app/data/user01?version=1
```


## Site navigation

For new pages to appear in the left hand navigation you need edit the `mkdocs.yml`
file in root of your repo. The navigation can also link out to other sites.

Alternatively, if there is no `nav` section in `mkdocs.yml`, a navigation section
will be created for you. However, you will not be able to use alternate titles for
pages, or include links to other sites.

Note that MkDocs uses `mkdocs.yml`, not `mkdocs.yaml`, although both appear to work.
See also <https://www.mkdocs.org/user-guide/configuration/>.

## Support

That's it. If you need support, make an issue in this repository.
