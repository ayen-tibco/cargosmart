# Copyright (c) 2017 TIBCO Software Inc.
#
# prep shell env for cmd line testing only
#
ssh_key=ec2_sbtest

# set aws credentials
export AWS_ACCESS_KEY_ID='abc'
export AWS_SECRET_ACCESS_KEY='abcd'

# set docker registry and credentials
DOCKER_REGISTRY=docker.io
DOCKER_REGISTRY_USERNAME=
DOCKER_REGISTRY_PASSWORD=
DOCKER_REGISTRY_AUTH=
DOCKER_REGISTRY_EMAIL=

# set location of ini settings for ec2.py 
export EC2_INI_PATH=./target/staging/ansible/aws/ec2.ini

# set hosts file to ec2 script instead of default
export ANSIBLE_HOSTS=./target/staging/ansible/aws/playbooks/inventory/ec2.py

# set SSH KEYS using ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
       eval `ssh-agent -s`
       ssh-add ~/.ssh/id_rsa_$ssh_key
fi
