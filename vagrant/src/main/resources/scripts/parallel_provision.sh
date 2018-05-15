# Copyright (c) 2017 TIBCO Software Inc.
#
if [ "${VAGRANT_PROVISIONER}" == "puppet_server" ]; then
    vagrant provision --provision-with puppet_server ${NODENAME_PREFIX}1 &
    # wait long enough for puppet master server to come up and confirm ssl certs from puppet agents
    sleep 120
    seq 2 ${INSTANCE_COUNT}| xargs -P 5 -I "NUM" bash -c "vagrant provision --provision-with puppet_server ${NODENAME_PREFIX}NUM"
else
    vagrant provision --provision-with ${VAGRANT_PROVISIONER}
fi
