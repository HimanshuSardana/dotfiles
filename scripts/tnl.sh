#!/bin/bash

LOCAL_PORT=$1

if [ -z "$LOCAL_PORT" ]; then
	echo "Usage: $0 <local port>"
fi

ssh -N -R 8888:localhost:$LOCAL_PORT himanshu@himanshu.co

echo "Tunneling to localhost:$LOCAL_PORT"
