#
#   Author: Rohith
#   Date: 2015-04-23 00:58:22 +0100 (Thu, 23 Apr 2015)
#
#  vim:ts=2:sw=2:et
#
FROM centos:centos7
MAINTAINER Rohith Jayawardene <gambol99@gmail.com>

RUN yum install -y ruby ruby-devel patch rubygems rubygem-httparty.noarch tar make gcc libxml2-devel
RUN gem install -V vcloud-tools -v 1.0.0
RUN gem install -V optionscrapper
RUN yum install -y ansible

