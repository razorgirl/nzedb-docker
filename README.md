# nzedb-docker

A Dockerfile to create a full [nZEDb](https://github.com/nZEDb/nZEDb) install in one go. It's intended to make setting up and testing nZEDb quick and painless.

Based on:

* Ubuntu Server 14.04 LTS
* MariaDB 10.0
* PHP 5.5.9
* nginx/1.4.6

All extras get installed, including `htop`, `nmon`, `vnstat`, `tcptrack`, `bwm-ng`, `mytop`, `memcached`, `ffmpeg` (the real one, *not* avconv), `mediainfo`, `p7zip`, `unrar` and `lame`.

## Installation

You need to have [Docker](http://www.docker.com/) installed. If you don't or are not familiar with Docker, please take a look at their web site. They do a really good job of getting you up and running.

### Build

```bash
docker build --tag nzedb/master .
```

### Run

```bash
docker run -d -p 8800:8800 --name nZEDb nzedb/master
```

### Info

In a new terminal run `docker ps`. The output will be similar to this:

```
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                           NAMES
f2653e243825        nzedb/master:latest    /bin/sh -c '/usr/sbi   6 hours ago         Up 6 hours          0.0.0.0:8800->8800/tcp   romantic_goldstine  nZEDb
```

Note the ports. `0.0.0.0:8800->8800/tcp` means that port 8800 from inside the container forwards to the same on your host. Thus, you can connect to the nZEDb interface via port 8800. Assuming you're running Docker on the same machine you're working on, open your browser with the URL `http://<HOST_IP>:8800/install`.

For more options on running and managing Docker containers, please consult the [Docker User Guide](https://docs.docker.com/userguide/).

## SSH Access

In the former Dockerfile I tried to get things running without `ssh`, which has provento be very difficult in the case of nZEDb. I still use Docker to separate processes and services but nZEDb is a complex beast with some rather, umhhh… *interesting* code. To make things easier, I configured things to run off the [phusion-docker base image](http://phusion.github.io/baseimage-docker/). Don't let their bold claim about doing things their way to be the right way get to you. It's simply one way to do it. In this case the most convenient alternative because the resulting container largely behaves like a virtual server.

There is a pre-generated SSH key set present. Of course, these keys are insecure and need to be replaced in production use. However, for development and testing, these are sufficient.

### Login

Use `docker inspect $(docker ps -aq nZEDb) | grep IPAddress` to get the container's IP address. The output:

```
        "IPAddress": "172.17.2.168",
```

Then log in:

```bash
ssh -i id_rsa root@172.17.2.168
```

## Configuration Options

### Have nZEDb folder outside of container, for.. you know.. development

```bash
docker run -d -p 8800:8800 --name nZEDb -v <LOCAL_NZEDB_FOLDER>:/var/www/nZEDb nzedb/master
```

This will map the local folder to respective folder inside of the image. Feel free to experiment!

### MariaDB

Most importantly, MariaDB contains just a `root` user -- no password.

### Timezone

Inside the Dockerfile, you should probably change your timezone. To do that, find

```
ENV TZ Europe/London
```

and replace. Also find

```
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/cli/php.ini
```

as well as

```
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/fpm/php.ini
```

and change the regex accordingly. You need to escape the forward slash with `\`.

## Notes

As Docker is 64-bit only, you need to have current hardware.
