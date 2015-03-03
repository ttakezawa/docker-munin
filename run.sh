#!/bin/bash

chown -R munin:www-data /var/lib/munin
chmod -R ug+rw          /var/lib/munin

consul-template \
  -log-level info \
  -consul=${CONSUL_PORT_8500_TCP_ADDR}:${CONSUL_PORT_8500_TCP_PORT} \
  -template "/etc/consul-templates/munin-hosts.ctmpl:/etc/munin/munin-conf.d/munin-hosts.conf" \
    >/consul-template.log 2>&1 &

cron

su - munin --shell=/bin/bash -c /usr/bin/munin-cron &

tail -F /consul-template.log \
        /var/log/munin/munin-update.log \
        /var/log/munin/munin-html.log \
        /var/log/munin/munin-cgi-graph.log \
        /var/log/munin/munin-cgi-html.log &

exec apache2ctl -DFOREGROUND
