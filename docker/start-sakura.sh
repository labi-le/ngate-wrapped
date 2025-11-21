#!/bin/bash
set -e

echo "cleaning up VNC locks..."
rm -rf /tmp/.X11-unix /tmp/.X1-lock
rm -rf /root/.vnc/*.log /root/.vnc/*.pid

echo "starting VNC Server on :1 (Port 5901)..."
vncserver :1 -geometry 1280x720 -depth 24 -localhost no

echo "starting Sakura Agent..."
cd /opt/sakura

if [ -f "./sakura" ]; then
    chmod +x ./sakura
    echo "Launching ./sakura from /opt/sakura..."
    exec ./sakura
else
    echo "Error: /opt/sakura/sakura not found!"
    ls -la /opt/sakura
    tail -f /dev/null
fi
