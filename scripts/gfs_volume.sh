#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-05-24 15:09:16 +0100 (Sun, 24 May 2015)
#
#  vim:ts=2:sw=2:et
#

usage() {
  cat <<EOF
  $(basename $0) -v|--volume NAME -r|--replica NUMBER
    -e|--env NAME           the environment / location to deploy to
    -v|--volume NAME        the name of the glusterfs volume to create
    -r|--replica NUMBER     the number of replicas to create  
    -n|--nfs                enable nfs support for the volume
    -h|--help               display this usage menu
EOF
  [ -n "$@" ] || {
     echo "error: $@";
     exit 1;
  }
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    -e|--env)       ENVIR=$2;    shift 2; ;;
    -v|--volume)    VOLUME=$2;   shift 2; ;;
    -r|--replicas)  REPLICAS=$2; shift 2; ;;
    -h|--help)      usage                 ;;
    *)              shift                 ;;
  esac
done

[ -z "$ENVIR"    ] && usage "you have not specified an location / environment to deploy"
[ -z "$VOLUME"   ] && usage "you have not specified a volume name"
[ -z "$REPLICAS" ] && usage "you have not specified a replica number"

ansible-playbook -i inventory/${ENVIR} -e volume=${VOLUME} -e replica=${REPLICAS} playbooks/procedures/create-gluster-volume.yml
