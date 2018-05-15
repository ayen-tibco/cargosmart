#!/bin/bash
# Copyright (c) 2017 TIBCO Software Inc.
#
yum makecache fast
rpm -Uvh http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
timedatectl set-timezone America/New_York
yum -y install ntp
ntpdate pool.ntp.org
systemctl enable ntpd
# install puppet agent
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppet-agent
source /etc/profile.d/puppet-agent.sh
puppet module install puppet-archive
puppet module install puppetlabs-docker
puppet module install puppetlabs-aws
