#!/bin/sh

VNSTAT_CONF="/etc/vnstat.conf"
NEW_INTERFACE="eth0"
INSTALL_LOCATION="/usr/share/bin/"

timestamp() {
	date +"%Y-%m-%d %T"
}

linux_distro() {
	cat /etc/*-release | grep "\bID\b" | cut -d "=" -f2
}

current_interface() {
	cat "$VNSTAT_CONF" | grep "Interface " | cut -d " " -f2 | cut -d '"' -f2
}

vnstat_owner() {
    stat -c %U /var/lib/vnstat
}

vnstat_status() {
    if [ "$(linux_distro)" = 'debian' ] || [ "$(linux_distro)" = 'ubuntu' ]
    then
        sudo service vnstat status | grep failed
    elif [ "$(linux_distro)" = 'centos' ]
    then
        sudo service vnstat status | grep dead
    fi
}

cron_exist() {
    crontab -l -u $CURRENTUSER
}

sed -i "s/CHANGEUSER/$USER/g" getAverages.py

if [ "$(linux_distro)" = 'debian' ] || [ "$(linux_distro)" = 'ubuntu' ]
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

    sudo apt install python3 -y

elif [ "$(linux_distro)" = '"centos"' ]
then
	echo "I'm CentOS"

    centos_version() {
        cat /etc/*-release | grep VERSION_ID | cut -d '"' -f2
    }

    if [ "$(centos_version)" = "8" ]
    then
        installed() {
            yum list installed | grep epel-release
        }

        if [ -n "$(installed)" ]
        then
            echo "Adding the RHEL7 Repo..."
            sudo yum install epel-release
            sudo yum update
        else
            echo "RHEL7 Repo already active."
        fi
    fi

    installed() {
        yum list installed | grep vnstat
    }

    if [ -z "$(installed)" ]
    then
        echo "vnstat not installed. Installing..."
	    sudo yum install vnstat -y
    else
        echo "vnstat already installed."
    fi

    sudo yum install python3 -y
else 
	echo "I don't know what I am"
fi

if [ "$(linux_distro)" != '"centos"' ]
then
    if [ $(vnstat_owner) != $CURRENTUSER ]
    then
        echo "Permission changes needed"
        sudo chown $CURRENTUSER -R /var/lib/vnstat/*
        sudo chgrp $CURRENTUSER -R /var/lib/vnstat/*
        sudo chown $CURRENTUSER -R /var/lib/vnstat
        sudo chgrp $CURRENTUSER -R /var/lib/vnstat
    else
        echo "No permission changes needed"
    fi
fi

# if we are in the Docker CentOS droplets, it seems that the "automatic selection" is fine, so ignore this section
if [ "$(linux_distro)" != '"centos"' ]
then
    if [ $(current_interface) != $NEW_INTERFACE ]
    then
        echo "Wrong interface selected. Changing it now..."
        sudo sed -i -e "s/$(current_interface)/$NEW_INTERFACE/g" "$VNSTAT_CONF"
    else
        echo "No need to change current vnstat interface"
    fi
fi

if [ -n "$(vnstat_status)" ]
then
    echo "vnstat service not running. starting now"
    sudo service vnstat start
else
    echo "vnstat service already running."
fi

if [ "$(linux_distro)" = 'debian' ] || [ "$(linux_distro)" = 'ubuntu' ]
then
    vnstat -u -i $NEW_INTERFACE
elif [ "$(linux_distro)" = 'centos' ]
then
    vnstat -add -i $NEW_INTERFACE
fi

# 2020-04-28 - ZLH - Decided it would be better to just git clone the repo, so this is unnecessary now
# wget -O stats.sh https://raw.CURRENTUSERcontent.com/ZLHysong/getStats/master/stats.sh
# wget -O getAverages.py https://raw.CURRENTUSERcontent.com/ZLHysong/getStats/master/getAverages.py


# This currently assumes no other cronjobs are runnin on the current system
# TODO - Add a proper check here to verify if the specific cronjobs we want to run are added or not
if [ -n "$(cron_exist)" ]
then
    echo "Cronjobs already added"
else
    echo "Cronjobs not running. Adding now..."
    cronjob="*/15 * * * * /home/ubuntu/getStats/stats.sh"
    (crontab -u $CURRENTUSER -l; echo "$cronjob" ) | crontab -u $CURRENTUSER -
    cronjob2="00 11 * * 5 /usr/bin/python3 /home/ubuntu/getStats/getAverages.py /home/ubuntu/getStats/log.txt"
    (crontab -u $CURRENTUSER -l; echo "$cronjob2" ) | crontab -u $CURRENTUSER -
fi