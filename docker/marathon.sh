#!/bin/sh

lookup_host() {
	echo "NSLOOKUP_1 $1" >&2
    nslookup "$1" | awk -v HOST="$1" '{ if ($2 == HOST) { getline; gsub(/^.*: /, ""); print $1 } }'
}

echo "HOST $HOST" >&2
echo "DOMAIN $DOMAIN" >&2
echo "PORT1 $PORT1" >&2

export MESSENGER_ADDRESS=`lookup_host ${HOST}${DOMAIN:+.$DOMAIN}`
export MESSENGER_PORT=$PORT1

echo "MESSENGER_ADDRESS $MESSENGER_ADDRESS" >&2
echo "MESSENGER_PORT $MESSENGER_PORT" >&2

exec /go/bin/eremetic
