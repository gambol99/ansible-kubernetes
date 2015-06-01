#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-05-29 12:08:09 +0100 (Fri, 29 May 2015)
#
#  vim:ts=2:sw=2:et
#

OVFTOOL=`which ovftool`

ovftool coreos_production_vmware_insecure.vmx coreos/coreos.insecure.ova
