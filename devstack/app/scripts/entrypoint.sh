#!/bin/bash

# Initializing environment
source /opt/anchovy/bin/init_environment.sh
source /etc/profile

NGINX_ENV=$(env | grep NGINX_)
for e in $(echo $NGINX_ENV); do
	var=$(echo $e | cut -d"=" -f1)
	val=$(echo $e | cut -d"=" -f2)
	if [ "$val" = "" ]; then
	       echo $var is not set...skipping
	fi
done


# Generate nginx template
export DOLLAR='$'
envsubst < /etc/nginx/conf.d/anchovy.tmpl > /etc/nginx/conf.d/anchovy.conf

# Change permissions for /var/www
chown -R www-data: /var/www

# Run composer install
while true; do
	if [ -d /var/www/anchovy/app ]; then
		echo "Directory exists"
		cd /var/www/anchovy && \
		composer install
		break
	fi
	sleep 5
done
# start supervisord
/usr/bin/supervisord -n -c /etc/supervisord.conf
