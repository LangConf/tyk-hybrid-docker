#!/bin/bash
USAGE="--> Usage: ./start.sh PORT SECRET ORGID APIKEY (REDIS HOST) (REDIS PORT) (REDIS PW)"

if [ -z "$1" ]
then
        echo "Please specify a listen port for Tyk"
        echo $USAGE
        exit
fi

if [ -z "$2" ]
then
        echo "Please specify a Tyk Secret (REST API)"
        echo $USAGE
        exit
fi

if [ -z "$3" ]
then
        echo "Please specify an Organisation ID"
        echo $USAGE
        exit
fi

if [ -z "$4" ]
then
        echo "Please specify an API Key"
        echo $USAGE
        exit
fi

REDISHOST=$5
if [ -z "$5" ]
then
        echo "Using Redis localhost"
        REDISHOST=localhost
fi

RPORT=$6
if [ -z "$6" ]
then
        echo "Using Redis default port"
        RPORT=6379
fi

TYK_GW_SLAVEOPTIONS_GROUPID=$8
if [ -z "$8" ]
then
        echo "Not assigning group ID"
        TYK_GW_SLAVEOPTIONS_GROUPID=""
fi

TYK_GW_DBAPPCONFOPTIONS_NODEISSEGMENTED=$9
if [ -z "$9" ]
then
        echo "Not using segmented db app config"
        TYK_GW_DBAPPCONFOPTIONS_NODEISSEGMENTED=""
fi

TYK_GW_DBAPPCONFOPTIONS_TAGS=$10
if [ -z "$10" ]
then
        echo "Not using db app tags config"
        TYK_GW_DBAPPCONFOPTIONS_TAGS=""
fi

REDISPW=$11
if [ -z "$11" ]
then
        echo "Using Redis without password"
        REDISPW=""
fi


cwd=$(pwd)
if [ ! -d "confs" ]; then
  mkdir confs
fi

PORT=$1
SECRET=$2
ORGID=$3
APIKEY=$4
IMAGE=tykio/tyk-hybrid-docker

docker stop tyk_hybrid && docker rm tyk_hybrid
docker pull $IMAGE:latest

docker run --restart always -v $cwd/confs:/etc/nginx/sites-enabled \
        -d --name tyk_hybrid \
        -p $PORT:$PORT \
        -p 80:80 \
        -e PORT=$PORT \
        -e SECRET=$SECRET \
        -e ORGID=$ORGID \
        -e APIKEY=$APIKEY \
        -e REDISHOST=$REDISHOST \
        -e REDISPW=$REDISPW \
        -e RPORT=$RPORT \
        -e REDISPW=$REDISPW \
        -e TYK_GW_SLAVEOPTIONS_GROUPID=$TYK_GW_SLAVEOPTIONS_GROUPID \
        -e TYK_GW_DBAPPCONFOPTIONS_NODEISSEGMENTED=$TYK_GW_DBAPPCONFOPTIONS_NODEISSEGMENTED \
        -e TYK_GW_DBAPPCONFOPTIONS_TAGS=$TYK_GW_DBAPPCONFOPTIONS_TAGS \
        -e BINDSLUG=1 \
        $IMAGE

# Add the following environment variable to disable the nginx service
# -e DISABLENGINX=1 \

# Add the following environment variable to have the node bind URLs to API IDs instead of Slugs
# -e BINDSLUG="" \
        
echo "Tyk Hybrid Node Running"
echo "- To test the node, use port $PORT"
