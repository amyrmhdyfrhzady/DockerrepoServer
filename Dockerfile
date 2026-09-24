FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    openssl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN apt update -y && apt install -y software-properties-common

RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update -y && apt install -y firefox

RUN apt update -y && apt install -y xubuntu-icon-theme

RUN touch /root/.Xauthority

RUN mkdir -p \
    /root/server-data/3x-ui \
    /root/server-data/3x-ui/bin \
    /root/server-data/3x-ui/log

RUN wget -q \
    https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz \
    -O /tmp/x-ui-linux-amd64.tar.gz \
    && mkdir -p /opt/3x-ui \
    && tar -xzf /tmp/x-ui-linux-amd64.tar.gz -C /opt/3x-ui --strip-components=1 \
    && chmod +x /opt/3x-ui/x-ui \
    && chmod +x /opt/3x-ui/bin/xray-linux-amd64 \
    && rm -f /tmp/x-ui-linux-amd64.tar.gz

ENV XUI_DB_FOLDER=/root/server-data/3x-ui
ENV XUI_LOG_FOLDER=/root/server-data/3x-ui/log
ENV XUI_BIN_FOLDER=/root/server-data/3x-ui/bin

EXPOSE 5901
EXPOSE 6080
EXPOSE 2053
EXPOSE 2096
EXPOSE 17432
EXPOSE 23187
EXPOSE 28641
EXPOSE 31472
EXPOSE 39756
EXPOSE 45283

CMD bash -c '\
mkdir -p /root/.vnc /root/server-data/3x-ui /root/server-data/3x-ui/bin /root/server-data/3x-ui/log && \
if [ ! -f /root/server-data/3x-ui/bin/xray-linux-amd64 ]; then \
    cp /opt/3x-ui/bin/xray-linux-amd64 /root/server-data/3x-ui/bin/xray-linux-amd64; \
fi && \
chmod +x /root/server-data/3x-ui/bin/xray-linux-amd64 && \ \
if [ ! -f /root/server-data/3x-ui/bin/geoip.dat ] && [ -f /opt/3x-ui/bin/geoip.dat ]; then \
    cp /opt/3x-ui/bin/geoip.dat /root/server-data/3x-ui/bin/geoip.dat; \
fi && \
if [ ! -f /root/server-data/3x-ui/bin/geosite.dat ] && [ -f /opt/3x-ui/bin/geosite.dat ]; then \
    cp /opt/3x-ui/bin/geosite.dat /root/server-data/3x-ui/bin/geosite.dat; \
fi && \
printf "%s\n" "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
chmod 600 /root/.vnc/passwd && \
vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 && \
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
cd /opt/3x-ui && \
XUI_DB_FOLDER=/root/server-data/3x-ui \
XUI_LOG_FOLDER=/root/server-data/3x-ui/log \
XUI_BIN_FOLDER=/root/server-data/3x-ui/bin \
./x-ui run & \
tail -f /dev/null'
