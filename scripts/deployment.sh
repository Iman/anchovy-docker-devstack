#!/bin/bash

export STACK_NAME=devstack
export SERVICE_NAME=app
JQ="./jq"

curl -s -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > ./jq
chmod u+x jq

id_list=$(curl -s -XGET -u $RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY $RANCHER_URL/v1/projects/1a5/containers | $JQ ".data[].id")

for i in $(echo $id_list); do
	temp="${i%\"}"
	temp="${temp#\"}"
	i=$temp
	
	cont_name=$(curl -s -XGET -u $RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY $RANCHER_URL/v1/projects/1a5/containers/$i | $JQ ".name")
	temp="${cont_name%\"}"
	temp="${temp#\"}"
	cont_name=$temp
	echo $cont_name
	if [ "$cont_name" = "${STACK_NAME}_${SERVICE_NAME}_app-base_1" ]; then
		curl -s -XPOST -u $RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY -H"Accept: application/json" -H"Content-Type: application/json" "$RANCHER_URL/v1/projects/1a5/containers/$i/?action=start"
	fi
	if [ "$cont_name" = "${STACK_NAME}_${SERVICE_NAME}_1" ]; then
		curl -s -XPOST -u $RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY -H"Accept: application/json" -H"Content-Type: application/json" "$RANCHER_URL/v1/projects/1a5/containers/$i/?action=restart"
	fi
done
