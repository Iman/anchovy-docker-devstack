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
	sleep 5
done
# Get the vault token
VAULT_TOKEN=$(curl -s $VAULT_ADDR/v1/auth/userpass/login/$VAULT_USER -d '{ "password": "'"$VAULT_PASS"'" }'| jq .auth.client_token)
temp="${VAULT_TOKEN%\"}"
temp="${temp#\"}"
export VAULT_TOKEN=$temp
