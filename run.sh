#!/bin/bash
set -eu
export KV_ROOT_DIR=~/kvstores
export VAULT_TOKEN="123456789"
docker rm -f dev-vault
docker run --cap-add=IPC_LOCK -d -p 8200:8200 -e VAULT_SERVER="http://127.0.0.1:8200" -e VAULT_DEV_ROOT_TOKEN_ID="$VAULT_TOKEN" --name=dev-vault vault
sleep 20
# root_token=$(docker logs dev-vault | egrep -o 'Root Token: ([a-Z0-9.]+)' | awk -F': ' '{print $2}')
echo "root token found=${VAULT_TOKEN}"
export VAULT_ADDR="http://localhost:8200"

echo "init"
vault secrets enable -path=jonathan.vautier@gmail.com kv
vault kv enable-versioning jonathan.vautier@gmail.com/
vault secrets enable -path=jonathan.vautier@ubisoft.com kv
vault kv enable-versioning jonathan.vautier@ubisoft.com/

store_name="secrets"
store_path="$KV_ROOT_DIR/$store_name"

for fullpath in $(find $store_path -type f )
do
    basename=$(basename $fullpath)
    path=${fullpath#$store_path/}
    path=${path%/$basename}
    vault kv put $path/$basename value=@$fullpath 1>/dev/null
done