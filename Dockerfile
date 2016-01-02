#
# nZEDb Dockerfile
# Create a quick and clean dev environment
#

# Use baseimage-docker
FROM phusion/baseimage:0.9.13

# Set maintainer
MAINTAINER razorgirl <https://github.com/razorgirl>

# Set correct environment variables.
ENV TZ Europe/London
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Regenerate SSH host keys.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Make sure system is up-to-date.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y curl git htop man software-properties-common unzip vim wget tmux ntp ntpdate time

# Install additional software.
RUN apt-get install -y htop nmon vnstat tcptrack bwm-ng mytop

# Install ffmpeg, mediainfo, p7zip-full, unrar and lame.
RUN \
  curl http://ffmpeg.gusari.org/static/64bit/ffmpeg.static.64bit.latest.tar.gz | tar xfvz - -C /usr/local/bin && \
  apt-get install -y unrar-free lame mediainfo p7zip-full

# Install MariaDB.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xcbcb082a1bb943db && \
  apt-get update && \
  echo "deb http://mirror2.hs-esslingen.de/mariadb/repo/10.0/ubuntu trusty main" > /etc/apt/sources.list.d/mariadb.list && \
  apt-get update && \
  apt-get install -y mariadb-server && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf

# Install Python MySQL modules.
RUN \
  apt-get install -y python-setuptools software-properties-common python3-setuptools python3-pip python-pip && \
  python -m easy_install pip && \
  easy_install cymysql && \
  easy_install pynntp && \
  easy_install socketpool && \
  pip list && \
  python3 -m easy_install pip && \
  pip3 install cymysql && \
  pip3 install pynntp && \
  pip3 install socketpool && \
  pip3 list

# Install PHP.
RUN apt-get install -y php5 php5-dev php-pear php5-gd php5-mysqlnd php5-curl php5-json php5-fpm
RUN sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/cli/php.ini
RUN sed -ri 's/(memory_limit =) ([0-9]+)/\1 -1/' /etc/php5/cli/php.ini
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/cli/php.ini
RUN sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/fpm/php.ini
RUN sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php5/fpm/php.ini
RUN sed -ri 's/;(date.timezone =)/\1 Europe\/London/' /etc/php5/fpm/php.ini

# Install simple_php_yenc_decode.
RUN \
  cd /tmp && \
  git clone https://github.com/kevinlekiller/simple_php_yenc_decode && \
  cd simple_php_yenc_decode/ && \
  sh ubuntu.sh && \
  cd ~ && \
  rm -rf /tmp/simple_php_yenc_decode/

# Install memcached.
RUN apt-get install -y memcached php5-memcached

# Install and configure nginx.
RUN \
  apt-get install -y nginx && \
  echo '\ndaemon off;' >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx && \
  mkdir -p /var/log/nginx && \
  chmod 755 /var/log/nginx
ADD nZEDb /etc/nginx/sites-available/nZEDb
RUN \
  unlink /etc/nginx/sites-enabled/default && \
  ln -s /etc/nginx/sites-available/nZEDb /etc/nginx/sites-enabled/nZEDb

# Clone nZEDb master and set directory permissions
RUN \
  mkdir /var/www && \
  cd /var/www && \
  git clone https://github.com/nZEDb/nZEDb.git && \
  chmod 777 /var/www/nZEDb/libs/smarty/templates_c && \
  chown www-data:www-data nZEDb/www -R

# Add services.
RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run
RUN mkdir /etc/service/php5-fpm && mkdir /var/log/php5-fpm
ADD php5-fpm.sh /etc/service/php5-fpm/run
RUN mkdir /etc/service/mariadb
ADD mariadb.sh /etc/service/mariadb/run

## Install SSH key.
ADD id_rsa.pub /tmp/key.pub
RUN cat /tmp/key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/key.pub

# Define mountable directories
VOLUME ["/etc/nginx/sites-enabled", "/var/log", "/var/www/nZEDb", "/var/lib/mysql"]

# Expose ports
EXPOSE 8800

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
