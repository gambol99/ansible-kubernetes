#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-06-03 23:36:29 +0100 (Wed, 03 Jun 2015)
#
#  vim:ts=2:sw=2:et
#

annonce() {
  [ -n "$@" ] || echo "** $@"
}

annonce "Creating a Cloudinit config drive"

mkdir -p /tmp/new-drive/openstack/latest
cp user_data /tmp/new-drive/openstack/latest/user_data
mkisofs -R -V config-2 -o configdrive.iso /tmp/new-drive
rm -rf /tmp/new-drive
