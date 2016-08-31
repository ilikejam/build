#!/bin/bash -xe
PATH=/usr/local/bin:$PATH
export PATH

exec > >(tee /root/ss.out | tee /dev/console)
exec 2> >(tee /root/ss.err | tee /dev/console)
if pgrep -x systemd
then
    while ! systemctl status multi-user.target
    do
        sleep 1
    done
elif [ -d /var/lock/subsys/ ]
then
    while [ ! -f /var/lock/subsys/local ] || [ $(echo `date +%s` - `date -r /var/lock/subsys/local +%s` | bc) -gt $(awk -F'.' '{print $1}' /proc/uptime) ]
    do
        sleep 1
    done
else
    while [ -f /etc/nologin ]
    do
        sleep 1
    done
fi
cd /root
tar xzvf ss.tar.gz
cd serverspec
if scl -l 2>/dev/null | grep ruby193 &> /dev/null
then
    scl enable ruby193 "rake spec modulelist=$1"
else
    rake spec modulelist=$1
fi
