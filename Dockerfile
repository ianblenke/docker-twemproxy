# expected values in etcd
#  - `/services/twemproxy/listen` : the host_ip:port the proxy will listen on
#  - `/services/twemproxy/servers/<num>` : enumeration of the redis servers for 01-N servers, in the format of host_ip:port
# example:
# etcdctl set /services/twemproxy/listen 10.10.100.1:6000
# etcdctl set /services/redis/01 10.10.100.11:6001
# etcdctl set /services/redis/02 10.10.100.12:6002

FROM ubuntu:14.04

MAINTAINER "John Goodall <jgoodall@ornl.gov>"

ENV DEBIAN_FRONTEND noninteractive

# Install basics
RUN apt-get update
RUN apt-get -qy install supervisor curl libtool make automake

# Install twemproxy
RUN curl -qL https://twemproxy.googlecode.com/files/nutcracker-0.3.0.tar.gz | tar xzf -
RUN cd nutcracker-0.3.0 && ./configure && make && mv src/nutcracker /twemproxy

# Install confd
RUN curl -qL https://github.com/kelseyhightower/confd/releases/download/v0.4.1/confd-0.4.1-linux-amd64 -o /confd && chmod +x /confd
RUN mkdir -p /etc/confd/{conf.d,templates}

# Copy local files
ADD run.sh /run.sh
ADD supervisor/twemproxy.conf /etc/supervisor/conf.d/twemproxy.conf
ADD confd/conf.d/twemproxy.toml /etc/confd/conf.d/twemproxy.toml
ADD confd/templates/twemproxy.tmpl /etc/confd/templates/twemproxy.tmpl

RUN chmod 755 /*.sh

EXPOSE 6000

CMD ["/run.sh"]