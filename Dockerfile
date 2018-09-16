#
# Ubuntu Desktop (Gnome) Dockerfile
#
# https://github.com/intlabs/Docker-Ubuntu-Desktop-Gnome
#

# Install GNOME3 and VNC server.
# (c) Pete Birley

# Pull base image.
FROM  ubuntu:16.04

# Setup enviroment variables
ENV DEBIAN_FRONTEND noninteractive

#Update the package manager and upgrade the system
RUN apt-get update && \
apt-get upgrade -y && \
apt-get update

# Installing fuse filesystem is not possible in docker without elevated priviliges
# but we can fake installling it to allow packages we need to install for GNOME
RUN apt-get install libfuse2 -y && \
cd /tmp ; apt-get download fuse && \
cd /tmp ; dpkg-deb -x fuse_* . && \
cd /tmp ; dpkg-deb -e fuse_* && \
cd /tmp ; rm fuse_*.deb && \
cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst && \
cd /tmp ; dpkg-deb -b . /fuse.deb && \
cd /tmp ; dpkg -i /fuse.deb

# Upstart and DBus have issues inside docker.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# Install GNOME and tightvnc server.
RUN apt-get update && apt-get install -y xorg gnome-core gnome-session-flashback tightvncserver

# Pull in the hack to fix keyboard shortcut bindings for GNOME 3 under VNC
COPY gnome-keybindings.pl /usr/local/etc/gnome-keybindings.pl
RUN chmod +x /usr/local/etc/gnome-keybindings.pl

# Add the script to fix and customise GNOME for docker
COPY gnome-docker-fix-and-customise.sh /usr/local/etc/gnome-docker-fix-and-customise.sh
RUN chmod +x /usr/local/etc/gnome-docker-fix-and-customise.sh

# Install protonmail related software
RUN apt-get install wget nginx -y \
  && wget https://protonmail.com/download/protonmail-bridge_1.0.6-2_amd64.deb \
  && apt-get install -y ./protonmail-bridge_1.0.6-2_amd64.deb \
  && rm -f ./protonmail-bridge_1.0.6-2_amd64.deb \
  && apt-get clean && apt-get autoclean

# Set up VNC
RUN mkdir -p /root/.vnc
COPY xstartup /root/.vnc/xstartup
RUN chmod 755 /root/.vnc/xstartup
COPY spawn-desktop.sh /usr/local/etc/spawn-desktop.sh
RUN chmod +x /usr/local/etc/spawn-desktop.sh
RUN apt-get install -y expect
COPY start-vnc-expect-script.sh /usr/local/etc/start-vnc-expect-script.sh
RUN chmod +x /usr/local/etc/start-vnc-expect-script.sh
COPY vnc.conf /etc/vnc.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)' > ~/.xinitrc && echo 'export SSH_AUTH_SOCK' >> ~/.xinitrc

# Define mountable directories.
VOLUME ["/root/.local"]

# Define default command.
CMD bash -C '/usr/local/etc/spawn-desktop.sh';'bash'

# Expose ports.
EXPOSE 5901 1144 1026
