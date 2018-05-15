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
# install puppet server
yum -y install puppetserver
PUPPET_FQDN_HOST=`domainname -f`
PUPPETCONF=/etc/puppetlabs/puppet/puppet.conf
PUPPET_HOST=`echo ${PUPPET_SERVER} | awk '{print tolower($0)}'`
grep -q 'dns_alt_names' $PUPPETCONF && sed -i.org -e "s/^dns_alt_names.*/dns_alt_names=$PUPPET_HOST, $PUPPET_FQDN_HOST, ${PUPPET_SERVER}/" $PUPPETCONF || echo "dns_alt_names = $PUPPET_HOST" >> $PUPPETCONF
# need to autosign puppet agents
grep -q 'autosign' $PUPPETCONF && sed -i.org -e "s/^autosign.*/autosign = true/" $PUPPETCONF || echo "autosign = true" >> $PUPPETCONF
rsync -av /vagrant/puppet_server/* /etc/puppetlabs/code
systemctl start puppetserver
systemctl enable puppetserver
#manually sign puppet agents certs
#puppet cert sign --all
