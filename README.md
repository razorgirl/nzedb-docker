# nzedb-docker

A Dockerfile to create a full [nZEDb](https://github.com/nZEDb/nZEDb) install in one go. It's intended to make setting up and testing nZEDb quick and painless.

Based on:

* Ubuntu Server 14.04 LTS
* MariaDB 10.1
* PHP 5.5.9
* nginx/1.4.6

All extras get installed, including `htop`, `nmon`, `vnstat`, `tcptrack`, `bwm-ng`, `mytop`, `memcached`, `ffmpeg` (the real one, *not* avconv), `mediainfo`, `p7zip`, `unrar` and `lame`.

## Installation

First off, edit your `/etc/hosts` file and add the following entry:

```
127.0.0.1 nzedb.local
```

I'm not sure how to do that on Windows. The `hosts` file is probably located in `c:\WINDOWS\system32\drivers\etc`.

With a recent version of [Docker](https://www.docker.com) installed, run the following command inside of the repository folder:

```bash
docker build --tag nzedb/master .
```

To run a new Docker container, enter:

```bash
docker run -it -p 50000:50000 nzedb/master
```

To run as a daemon:

```bash
docker run -d -p 50000:50000 nzedb/master
```

In a new terminal run `docker ps`. The output will be similar to this:

```
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                           NAMES
f2653e243825        nzedb/master:latest    /bin/sh -c '/usr/sbi   6 hours ago         Up 6 hours          0.0.0.0:50000->50000/tcp   romantic_goldstine
```

Note the ports. `0.0.0.0:50000->50000/tcp` means that port 50000 from inside the container forwards to the same on your host. Thus, you can connect to the nZEDb interface via port 50000. Assuming you're running Docker on the same machine you're working on, open your browser with the URL `http://nzedb.local:50000/install`.

For more options on running and managing Docker containers, please consult the [Docker User Guide](https://docs.docker.com/userguide/).

## Accessing the container without ssh

The container does not contain a ssh daemon. However, without sacrificing functionality, you can use `nsenter` to open a shell for debugging or general access.

To install the tool, run

```
docker run -v /usr/local/bin:/target jpetazzo/nsenter
```

then add this to your bash `.profile`, zsh `.zshrc` or to the user config file of whatever shell you may be using

```
function docker-enter {
        NSENTERPID=$(docker inspect --format {{.State.Pid}} $1)
        nsenter --target $NSENTERPID --mount --uts --ipc --net --pid /bin/bash
}
```

Now you can open a bash shell just by entering:

```
docker-enter f2653e243825
```

_f2653e243825_ is just an example for your container id. You can find this out with `docker ps` (see above).

If you're using Mac OS X or Windows, you're using `boot2docker`. In this case, setup is slightly more complex. Follow the instructions [here](http://blog.sequenceiq.com/blog/2014/07/05/docker-debug-with-nsenter-on-boot2docker/).

## Configuration Options

Most importantly, MariaDB contains just a `root` user -- no password.

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
