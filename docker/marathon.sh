#!/bin/sh

lookup_host() {
    nslookup "$1" | awk -v HOST="$1" '{ if ($2 == HOST) { getline; gsub(/^.*: /, ""); print $1 } }'
}

echo "HOST $HOST"
echo "DOMAIN $DOMAIN"
echo "PORT1 $PORT1"

export MESSENGER_ADDRESS=`lookup_host ${HOST}${DOMAIN:+.$DOMAIN}`
export MESSENGER_PORT=$PORT1

echo "MESSENGER_ADDRESS $MESSENGER_ADDRESS"
echo "MESSENGER_PORT $MESSENGER_PORT"

exec /go/bin/eremetic
