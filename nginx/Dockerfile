#
# nZEDb nginx Dockerfile
# Create a quick and clean dev environment
#

# Use baseimage-docker
FROM alpine:3.3
MAINTAINER razorgirl <https://github.com/razorgirl>

# Set correct environment variables.
ENV TZ Europe/London
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Make sure system is up-to-date.
RUN \
  apk update && \
  apk upgrade

# Install and configure nginx.
RUN \
  set -x && \
  addgroup -g 82 -S www-data && \
  adduser -u 82 -D -S -G www-data www-data
RUN apk add nginx
ADD nginx.conf /etc/nginx/nginx.conf
RUN \
  mkdir /run/nginx && \
  chown -R www-data /run/nginx

# Expose ports
EXPOSE 8800

# Run.
CMD ["nginx"]

# Clean up when done.
RUN rm -rf /tmp/* /var/tmp/*
