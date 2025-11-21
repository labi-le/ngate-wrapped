FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PASSWORD=sakura

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates \
        tigervnc-standalone-server tigervnc-common tigervnc-tools fluxbox \
        libgtk-3-0 libnss3 libasound2 libxss1 dbus-x11 xterm \
        libglib2.0-0 libgbm1 \
        libusb-1.0-0 systemd \
        && \
    rm -rf /var/lib/apt/lists/*

RUN echo "downloading Sakura Agent..." && \
    curl -A 'Mozilla/5.0' -k -L -o sakura-agent.deb 'https://cloud.dit.mos.ru/s/dJSEr2LcmaHF4zA/download?path=%2FLinux&files=sakura-agent-2.35.5.deb' && \
    \
    if [ -f /usr/bin/systemctl ]; then mv /usr/bin/systemctl /usr/bin/systemctl.bak; fi && \
    echo '#!/bin/sh' > /usr/bin/systemctl && \
    echo 'exit 0' >> /usr/bin/systemctl && \
    chmod +x /usr/bin/systemctl && \
    \
    dpkg -i sakura-agent.deb && \
    \
    rm /usr/bin/systemctl && \
    if [ -f /usr/bin/systemctl.bak ]; then mv /usr/bin/systemctl.bak /usr/bin/systemctl; fi && \
    \
    rm sakura-agent.deb

RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/sh\nexec fluxbox' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

COPY start-sakura.sh /start-sakura.sh
RUN chmod +x /start-sakura.sh

EXPOSE 5901

ENTRYPOINT ["/start-sakura.sh"]
