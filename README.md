## Ubuntu Desktop (GNOME) Dockerfile


This repository contains the *Dockerfile* and *associated files* for setting up a container with Ubuntu, GNOME and TigerVNC for [Docker](https://www.docker.io/).

* The VNC Server currently defaults to 1366*768 24bit.

### Dependencies

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)


### Installation

1. Install [Docker](https://www.docker.io/).

	For an Ubuntu 14.04 host the following commands will get you up and running:

	`sudo apt-get -y update && \

	sudo apt-get -y install docker.io && \

	sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker && \

	sudo restart docker.io`


2. You can then pull the file:

	`sudo docker pull blacs30/dockerfile-ubuntu-gnome`


	Or alternatively build an image from the Dockerfile:

	`sudo docker build -t="blacs30/dockerfile-ubuntu-gnome" github.com/blacs30/Dockerfile-Ubuntu-Gnome`


### SuperQuick Install


	This will get you going superfast - one line! - from a fresh Ubuntu install (rememebr to update the /etc/hosts file to relect your hostname at 127.0.1.1)

	sudo apt-get -y update && \
	sudo apt-get -y install docker.io && \
	sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker && \
	sudo restart docker.io && \
	sudo docker pull blacs30/dockerfile-ubuntu-gnome && \
	sudo docker run -it --rm -p 5901:5901 blacs30/dockerfile-ubuntu-gnome


### Usage

#### Starting

* Change the port number to run multiple instances on the same host (remeber to open the ports for tcp ingress)

* this will run and drop you into a session:

	`sudo docker run -it --rm -p 5901:5901 blacs30/dockerfile-ubuntu-gnome`

* or for silent running:

	`sudo docker run -it -d -p 5901:5901 blacs30/dockerfile-ubuntu-gnome`

#### Connecting to instance

* Connect to `vnc://<host>:5901` via your VNC client. currently the password is hardcoded to "Your_PASS"

#### Notes

* You can use the following command from within the container to kill the vnc server:

	`USER=root vncserver -kill :1`

* Then run the following command from within the container to restart start the vnc server, the flags are optional but pretty self explanatory.

	`USER=root vncserver :1 -geometry 1024x768 -depth 24`

#### Protonmail usage

It is possible to run the Protonmail Bridge Inside this container. The Bridge comes pre-installed.
How to add new Protonmail accounts to the bridge:

* Establish a VNC session
* Open a terminal window in the VNC session
* Run `Desktop-Bridge --cli` (the GUI had issues recognizing my keyboards corretly via the VNC session from a Mac)
* Add the account(s)

The first time an account is added the gnome-keyring is asking for master password. This password has to be entered after every reboot.

Exit the cli again and start the gui, e.g. via the Menu bar or again via the terminal `Desktop-Bridge &`

See the configuration and use an Email client of your choice to connect.

The configuration for Protonmail is stored basically in the gnome-keyring. That can be bind-mounted to save the data e.g. outside of docker or in a docker-volume.

This is an example and functioning `docker run` command:
```
docker run -it -v $(pwd)/protonmail:/root/.local -d --cap-add ipc_lock -p 5901:5901 -p 1026:1026 -p 1144:1144 blacs30/dockerfile-ubuntu-gnome
```

The parameter `--cap-add ipc_lock` is important as otherwise the gnome-keyring cannot function. Alternatively --privileged could be also used.
