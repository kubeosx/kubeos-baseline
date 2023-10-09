# Read system health check

path "secrets/kubeos/*"
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

path "kv/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}