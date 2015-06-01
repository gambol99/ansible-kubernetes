#!/bin/bash -x 
#
#   Author: Rohith
#   Date: 2015-05-28 23:15:35 +0100 (Thu, 28 May 2015)
#
#  vim:ts=2:sw=2:et
#

annonce() {
  [ -n "$@" ] && echo "** $@"
}

REFERENCE=$1

[ -z "${REFERENCE}" ] && {
  annonce "no reference to remove from source code";
  exit 0;
}

annonce "removing the reference: ${REFERENCE}"

find . -type f -exec grep -l "${REFERENCE}" {} \;
