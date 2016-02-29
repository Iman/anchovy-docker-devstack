#!/bin/bash

if [ -z $VAULT_USER ]; then
	echo "VAULT_USER not set... Exiting"
	exit 1
fi

if [ -z $VAULT_PASS ]; then
	echo "VAULT_PASS not set.. Exiting"
	exit 1
fi

# Check if vault is ready
while true; do
	VAULT_TOKEN=$(curl -s $VAULT_ADDR/v1/auth/userpass/login/$VAULT_USER -d '{ "password": "'"$VAULT_PASS"'" }'| jq '.errors[0]')
	if [ "$VAULT_TOKEN" = "null" ]; then
	       echo "Authenticated successfully.."
	       break
        fi	
	echo "Error with authentication with vault..Trying again"
	sleep 2
done
# Get the vault token
VAULT_TOKEN=$(curl -s $VAULT_ADDR/v1/auth/userpass/login/$VAULT_USER -d '{ "password": "'"$VAULT_PASS"'" }'| jq .auth.client_token)
temp="${VAULT_TOKEN%\"}"
temp="${temp#\"}"
VAULT_TOKEN=$temp

# Set the configuration for mysql from vault
MYSQL_DATABASE=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_db  | jq .data.value)
temp="${MYSQL_DATABASE%\"}"
temp="${temp#\"}"
export MYSQL_DATABASE=$temp

MYSQL_USER=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_user  | jq .data.value)
temp="${MYSQL_USER%\"}"
temp="${temp#\"}"
export MYSQL_USER=$temp

MYSQL_PASSWORD=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_pass  | jq .data.value)
temp="${MYSQL_PASSWORD%\"}"
temp="${temp#\"}"
export MYSQL_PASSWORD=$temp

MYSQL_ROOT_PASSWORD=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/mysql_root_password  | jq .data.value)
temp="${MYSQL_ROOT_PASSWORD%\"}"
temp="${temp#\"}"
export MYSQL_ROOT_PASSWORD=$temp

/entrypoint.sh mysqld
