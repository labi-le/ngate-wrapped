#!/bin/bash
set -e

if [ -z "$LOGIN" ] || [ -z "$PASSWORD" ] || [ -z "$HOST" ]; then
    echo "Error: LOGIN, PASSWORD, and HOST variables are required"
    exit 1
fi

echo "create tun device"
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

echo "starting ngate daemon"
/opt/cprongate/ngatetun &
NGATE_PID=$!

sleep 2

echo "starting vpn client"
echo "login to $HOST as $LOGIN"

(
    echo "try to ping jira.mos.ru..."
    while true; do
        if ping -c1 -W1 jira.mos.ru >/dev/null 2>&1; then
            ip=$(getent hosts jira.mos.ru | awk '{print $1}' | head -n1)
            echo "победа! jira.mos.ru ($ip) доступен"
            break
        fi
        sleep 2
    done
) &

# show debug logs
# exec /opt/cprongate/ngateconsoleclient -vvvv -l /dev/stdout -u "$LOGIN" -p "$PASSWORD" "$HOST"

exec /opt/cprongate/ngateconsoleclient -l /dev/stdout -u "$LOGIN" -p "$PASSWORD" "$HOST"
