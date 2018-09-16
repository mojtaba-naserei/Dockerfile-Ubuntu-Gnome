#!/bin/sh
# (c) Pete Birley

if [[ -f /tmp/.X1-lock ]]; then rm -rf /tmp/.X1-lock; fi
if [[ -d /tmp/.X11-unix ]]; then rm -rf /tmp/.X11-unix; fi

# start nginx
nginx -t && /etc/init.d/nginx start

#this sets the vnc password
/usr/local/etc/start-vnc-expect-script.sh
#fixes a warning with starting nautilus on firstboot - which we will always be doing.
mkdir -p ~/.config/nautilus
#this starts the vnc server
USER=root vncserver :1 -geometry 1366x768 -depth 24
