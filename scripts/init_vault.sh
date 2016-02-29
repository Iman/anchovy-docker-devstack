#!/bin/bash

vault auth-enable userpass
vault write secret/wordpress_user value=wpuser
vault write secret/wordpress_pass value=wppass
vault write secret/wordpress_db value=wordpress
# environment
vault write secret/blackfire_server_id value=00000000000
vault write secret/blackfire_server_token value=ABBBBBBBAAA
vault write secret/symfony_access_token value=6565656565656565
##
vault write secret/repo_key value=@../keys/repo_key
vault write auth/userpass/users/dev password=myPASS123 policies=root
