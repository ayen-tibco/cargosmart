# Copyright (c) 2017 TIBCO Software Inc.
#
set -x
STATUS=`vagrant status| grep -c 'running'`
if [ "$STATUS" -gt "0" ]; then 
    vagrant destroy -f
fi

if [ "$UPDATEHOSTSLOCAL" == "true" ]; then
    if [ -f .vagrant/hostmanager/id ]; then
        vid=`cat .vagrant/hostmanager/id`
        if grep -q $vid /etc/hosts; then
            vagrant hostmanager
        else
            echo "Vagrant id $vid not found in /etc/hosts file."
        fi
    else
        echo "No vagrant id file found in $PWD/.vagrant/hostmanager/id."
    fi
fi

# return result only
exit $EXIT_RESULT
