#!/bin/bash
#
#   Author: Rohith
#   Date: 2015-06-04 17:03:53 +0100 (Thu, 04 Jun 2015)
#
#  vim:ts=2:sw=2:et
#

annonce() {
  [ -n "$@" ] && { echo "** $@"; }
}

# set some defaults
API="api.vcd.portal.skyscapecloud.com"
CATALOG="CoreOS"
VDC="DEV_TEST_FARN (IL2-DEVTEST-BASIC)"
OVERWR=""

usage() {
  cat <<EOF
  Usage: $(basename $0)
  Description: upload an iso image to vcloud 

  -u|--username USERNNAME       : the username for vcloud api 
  -p|--password PASSWORD        : the password for the vcloud api 
  -o|--org ORGANIZATION         : the organization we are uploading to  
  -c|--catalog CATALOG          : the catalog we are uploading the image to 
  -n|--name NAME                : the name of the media (defaults: ${CATALOG})
  -a|--api URL                  : the url of the vcloud api (defaults: ${API})
  -i|--iso FILE                 : the path of the iso file we are uploading
  -v|--vdc VDC                  : the name of the vdc we are uploading 
  -w|--overwrite                : overwrite the image if it already exists 
  -h|--help                     : display this usage menu

EOF
  [ -n "$@" ] && {
    echo "error: $@";
    exit 1;
  }
  exit 0
} 

# step: check we have the ovftool
OVFTOOL=`which ovftool`
[ -z "$OVFTOOL" ] && usage "unable to find the ovftool tool the PATH"

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--username)  USERNAME=$2;  shift 2 ;;
    -p|--password)  PASSWORD=$2;  shift 2 ;;
    -c|--catalog)   CATALOG=$2;   shift 2 ;;
    -o|--org)       ORG=$2;       shift 2 ;;
    -n|--name)      NAME=$2;     shift 2 ;;
    -a|--api)       API=$2;       shift 2 ;;
    -i|--iso)       ISO=$2;       shift 2 ;;
    -v|--vdc)       VDC=$2;       shift 2 ;;
    -w|--overwrite) OVERWR="-o"  
                    shift
                    ;;         
    -h|--help)      usage;        ;;
    *)              shift
                    ;;
  esac
done

[ -z "$USERNAME" ] && usage "you have not specified a username for vcloud"
[ -z "$PASSWORD" ] && usage "you have not specified a password for vcloud"
[ -z "$API" ]      && usage "you have not specified a api endpoint for vcloud"
[ -z "$ORG" ]      && usage "you have not specified the organization"
[ -z "$NAME" ]     && usage "you need to specify a name for the media image (e.g medis.iso)"
[ -z "$ISO" ]      && usage "you have not specified a cdrom image to upload"
[ -z "$VDC" ]      && usage "you have not specified a vdc to upload the image to"
[ -z "$CATALOG" ]  && usage "you have not specified the catalog to upload the image"
[ -f "$ISO" ]      || usage "the iso image: $ISO does not exist"

annonce "Uploading the image: ${ISO} -> Name: ${NAME}, Catalog: ${CATALOG} VDC: ${VDC}"

$OVFTOOL -st=ISO $OVERWR --vCloudTemplate=false $ISO "vcloud://${USERNAME}:${PASSWORD}@${API}?vdc=${VDC}&org=${ORG}&media=${NAME}&catalog=${CATALOG}"

#exit 0
