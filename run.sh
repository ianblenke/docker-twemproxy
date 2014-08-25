#!/bin/sh

# Run docker run with -e ETCD_HOST=<ip>:<port>
if [ -n "${ETCD_HOST:+x}" ]; then
  mv /etc/supervisor/supervisord.conf /tmp/supervisord.conf
  sed -e "/confd -node/s/127.0.0.1:4001/${ETCD_HOST}/" /tmp/supervisord.conf > /etc/supervisor/supervisord.conf
fi
# Run docker run with -e CONSUL_HOST=<ip>:<port>
if [ -n "${CONSUL_HOST}" ]; then
  mv /etc/supervisor/supervisord.conf /tmp/supervisord.conf
  sed -e "s/confd -node=\"http://127.0.0.1:4001\"/-consul -consul-addr ${CONSUL_HOST}/" /tmp/supervisord.conf > /etc/supervisor/supervisord.conf
fi

# for debugging
cat /etc/supervisor/supervisord.conf

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf