#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-05-18 14:40:40 +0100 (Mon, 18 May 2015)
#
#  vim:ts=2:sw=2:et
#

alias haconfig="show_haproxy_config"
alias haenter="enter_haproxy_container"

enter_haproxy_container() {
  sudo /usr/bin/docker exec -ti gateway /bin/bash
}

show_haproxy_config() {
  sudo /usr/bin/docker exec -ti gateway cat /etc/haproxy/haproxy.cfg
}
