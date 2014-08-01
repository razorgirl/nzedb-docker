# nzedb-docker

A Dockerfile to create a full [nZEDb](https://github.com/nZEDb/nZEDb) install in one go. It's intended to make setting up and testing nZEDb quick and painless.

Based on:

* Ubuntu Server 14.04 LTS
* MariaDB 10.1
* PHP 5.5.9
* nginx/1.4.6

All extras get installed, including `htop`, `nmon`, `vnstat`, `tcptrack`, `bwm-ng`, `mytop`, `memcached`, `ffmpeg` (the real one, *not* avconv), `mediainfo`, `p7zip`, `unrar` and `lame`.

## Installation

With a recent version of [Docker](https://www.docker.com) installed, run the following command inside of the repository folder:

```bash
docker build --tag nzedb/master .
```

To run a new Docker container, enter:

```bash
docker run -itP nzedb/master
```

To run as a daemon:

```bash
docker run -dP nzedb/master
```

In a new terminal run `docker ps`. The output will be similar to this:

```
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                           NAMES
f2653e243825        nzedb/master:latest    /bin/sh -c '/usr/sbi   6 hours ago         Up 6 hours          0.0.0.0:49153->443/tcp, 0.0.0.0:49154->80/tcp   romantic_goldstine
```

Note the ports. `0.0.0.0:49154->80/tcp` means you can connect to the nZEDb interface via port 49154. Assuming you're running Docker on the same machine you're working on, open your browser with the URL `http://localhost:49154/install`.

For more options on running and managing Docker containers, please consult the [Docker User Guide](https://docs.docker.com/userguide/).

## Configuration Options

Inside the Dockerfile, you should probably change your timezone. To do that, find

```
RUN echo "Europe/London" >> /etc/timezone
```

and change "Europe/London" to an appropriate one.

Also, find

```
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/cli/php.ini
```

as well as

```
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/fpm/php.ini
```

and change the regex accordingly. You need to escape the forward slash with `\`.

## Notes

This image should work on 32- and 64-bit systems with the exception of `ffmpeg`, that's statically linked to 64-bit libraries. If you're working on a 32-bit system, you will want to change the Dockerfile to download and process <http://ffmpeg.gusari.org/static/32bit/ffmpeg.static.32bit.latest.tar.gz> instead.
