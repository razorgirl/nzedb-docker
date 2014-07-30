# nzedb-docker

A Dockerfile to create a full nZEDb install in one go. It is intended to make setting up and testing nZEDb quick and painless.

## Installation

With a recent version of [Docker](https://www.docker.com) installed, run the following command inside of the repository folder:

```bash
docker build --tag nzedb/master .
```

To run a new Docker container, enter:

```bash
docker run -itP nzedb/master
```

In a new terminal run `docker ps`. The output is similar to this:

```
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                           NAMES
f2653e243825        nzedb/master:latest    /bin/sh -c '/usr/sbi   6 hours ago         Up 6 hours          0.0.0.0:49153->443/tcp, 0.0.0.0:49154->80/tcp   romantic_goldstine
```

Note the ports. `0.0.0.0:49154->80/tcp` means you can connect to the nZEDb interface via port 49154. Assuming you're running Docker on the same machine you're working on, open your browser with the URL `http://localhost:49154`.
