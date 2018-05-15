# Copyright (c) 2017 TIBCO Software Inc.
#
set -x
sleep 120
killall vagrant-aws
killall vagrant ruby
if [ ! -f $PWD/Vagrantfile ]; then
        vagrantfiledir=`find ./ -path ./*src -prune -o -name Vagrantfile -exec dirname {} \; | tail -n 1`
        if [ ! -z $vagrantfiledir ]; then
            cd $vagrantfiledir
        else
            exit 1
        fi
fi

./vagrant_destroy_vms.sh

