# Copyright (c) 2017 TIBCO Software Inc.
#
# prep shell env for cmd line testing only
#
ssh_key=azure_sbtest

# set azure credentials
export AZURE_CLIENT_ID= 
export AZURE_SECRET=
export AZURE_SUBSCRIPTION_ID=
export AZURE_TENANT=
export AZURE_AD_USER=
export AZURE_PASSWORD=

# install azure python sdk
if [ `pip list --disable-pip-version-check | grep -c "azure (2.0.0rc5)"` = 0 ];then
    pip install "azure==2.0.0rc5"
fi


# set hosts file to azure inventory script instead of default
export ANSIBLE_HOSTS=./target/staging/ansible/azure/playbooks/inventory/azure_rm.py

# set SSH KEYS using ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
       eval `ssh-agent -s`
       ssh-add ~/.ssh/id_rsa_$ssh_key
fi
