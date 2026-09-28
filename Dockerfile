FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
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
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install --no-install-recommends -y xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080
EXPOSE 2096
EXPOSE 17432
EXPOSE 23187
EXPOSE 28641
EXPOSE 31472
EXPOSE 39756
EXPOSE 45283

CMD bash -c '\
mkdir -p /root/.vnc && \
printf "%s\n" "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
chmod 600 /root/.vnc/passwd && \
vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 && \
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
tail -f /dev/null'
