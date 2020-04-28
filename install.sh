#!/bin/sh

VNSTAT_CONF="/etc/vnstat.conf"
USER="root"
NEW_INTERFACE="eth0"
INSTALL_LOCATION="/usr/share/bin/"

timestamp() {
	date +"%Y-%m-%d %T"
}

linux_distro() {
	cat /etc/*-release | grep "\bID\b" | cut -d "=" -f2
}

current_interface() {
	cat "$VNSTAT_CONF" | grep Interface | cut -d " " -f2 | cut -d '"' -f2
}

vnstat_owner() {
    stat -c %U /var/lib/vnstat
}

vnstat_status() {
    if [ "$(linux_distro)" = 'debian' ]
    then
        sudo service vnstat status | grep failed
    elif [ "$(linux_distro)" = 'centos' ]
    then
        sudo service vnstat status | grep dead
    fi
}

cron_exist() {
    crontab -l -u $USER
}

if [ "$(linux_distro)" = 'debian' ]
then
	echo "Im Debian!"
    installed() {
        dpkg -l | grep vnstat
    }
    if [ -z "$(installed)" ]
    then
        echo "vnstat not installed. Installing..."
	    sudo apt-get install vnstat -y
    else
        echo "vnstat already installed."
    fi
elif [ "$(linux_distro)" = '"centos"' ]
then
	echo "I'm CentOS"

    centos_version() {
        cat /etc/*-release | grep VERSION_ID | cut -d '"' -f2
    }

    if [ "$(centos_version)" = "8" ]
    then
        sudo yum install epel-release
        sudo yum update
    fi

    installed() {
        yum list installed | grep vnstat
    }

    if [ -z "$installed" ]
    then
        echo "vnstat not installed. Installing..."
	    sudo yum install vnstat -y
    else
        echo "vnstat already installed."
    fi
else 
	echo "I don't know what I am"
fi


if [ $(vnstat_owner) != $USER ]
then
    echo "Permission changes needed"
    sudo chown $USER -R /var/lib/vnstat/*
    sudo chgrp $USER -R /var/lib/vnstat/*
else
    echo "No permission changes needed"
fi


if [ $(current_interface) != $NEW_INTERFACE ]
then
    echo "Wrong interface selected. Changing it now..."
    echo "Using command " + "s/$(current_interface)/$NEW_INTERFACE/g"
    sudo sed -i -e "s/$(current_interface)/$NEW_INTERFACE/g" "$VNSTAT_CONF"
else
    echo "No need to change current vnstat interface"
fi

if [ -n "$(vnstat_status)" ]
then
    echo "vnstat service not running. starting now"
    sudo service vnstat start
else
    echo "vnstat service already running."
fi

if [ "$(linux_distro)" = 'debian' ]
then
    vnstat -u -i $NEW_INTERFACE
elif [ "$(linux_distro)" = 'centos' ]
then
    vnstat -add -i $NEW_INTERFACE
fi

# 2020-04-28 - ZLH - Decided it would be better to just git clone the repo, so this is unnecessary now
# wget -O stats.sh https://raw.githubusercontent.com/ZLHysong/getStats/master/stats.sh
# wget -O getAverages.py https://raw.githubusercontent.com/ZLHysong/getStats/master/getAverages.py

if [ -n "$(cron_exist)" ]
then
    echo "Cronjob already added"
else
    echo "Cronjob not running. Adding now..."
    cronjob="*/15 * * * * /home/user/getStats/stats.sh"
    (crontab -u $USER -l; echo "$cronjob" ) | crontab -u $USER -
fi