#!/bin/sh

if [ -z $GIT_REPO ]; then
	echo "GIT_REPO not set... Exiting"
	exit 1
fi

if [ -z $VAULT_USER ]; then
	echo "VAULT_USER not set... Exiting"
	exit 1
fi

if [ -z $VAULT_PASS ]; then
	echo "VAULT_PASS not set.. Exiting"
	exit 1
fi

git config --global user.email "@GIT_MAIL"
git config --global user.name "@GIT_NAME"

# Check if vault is ready
while true; do
	VAULT_TOKEN=$(curl -s $VAULT_ADDR/v1/auth/userpass/login/$VAULT_USER -d '{ "password": "'"$VAULT_PASS"'" }'| jq '.errors[0]')
	if [ "$VAULT_TOKEN" = "null" ]; then
	       echo "Authenticated successfully.."
	       break
        fi
	echo "Error with authentication with vault..Trying again"
	sleep 5
done
# Get the vault token
VAULT_TOKEN=$(curl -s $VAULT_ADDR/v1/auth/userpass/login/$VAULT_USER -d '{ "password": "'"$VAULT_PASS"'" }'| jq .auth.client_token)
temp="${VAULT_TOKEN%\"}"
temp="${temp#\"}"
VAULT_TOKEN=$temp
REPO_KEY=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/repo_key | jq .data.value)
temp="${REPO_KEY%\"}"
temp="${temp#\"}"
REPO_KEY=$temp
echo -e $REPO_KEY > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
echo -e "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
echo -e "LogLevel=quiet" >> ~/.ssh/config

# Clone the repo if it is not exist
if [ ! -d "/var/www/anchovy" ]; then
	git clone -b $GIT_BRANCH $GIT_REPO /var/www/anchovy \
	&& cd /var/www/anchovy
fi

# Pull the GIT_BRANCH branch
cd /var/www/anchovy \
&& git pull

# Set the configuration for wordpress from vault
WORDPRESS_DB=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_db  | jq .data.value)
temp="${WORDPRESS_DB%\"}"
temp="${temp#\"}"
WORDPRESS_DB=$temp

WORDPRESS_USER=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_user  | jq .data.value)
temp="${WORDPRESS_USER%\"}"
temp="${temp#\"}"
WORDPRESS_USER=$temp

WORDPRESS_PASS=$(curl -s -H"X-Vault-Token: $VAULT_TOKEN" -XGET $VAULT_ADDR/v1/secret/wordpress_pass  | jq .data.value)
temp="${WORDPRESS_PASS%\"}"
temp="${temp#\"}"
WORDPRESS_PASS=$temp

sed -e "s/database_name_here/$WORDPRESS_DB/
s/username_here/$WORDPRESS_USER/
s/localhost/$WORDPRESS_HOST/
s/password_here/$WORDPRESS_PASS/ " blog/wp-config-sample.php > blog/wp-config.php

# Set the configuration for symfony from vault
#sed -i -e "s/server:.*/server: mongodb:\/\/$MONGODB_HOST:27017/g" app/config/config.yml

# Cleanup
rm ~/.ssh/id_rsa
unset VAULT_USER
unset VAULT_PASS

exit 0
