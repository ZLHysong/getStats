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
    crontab -l -u $USER
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
elif  [ "$(linux_distro)" = '"rhel"' ]
then

	echo "I am RHEL"	

else 
	echo "I don't know what I am"
fi

if [ "$(linux_distro)" != '"centos"' ]
then
    if [ $(vnstat_owner) != $USER ]
    then
        echo "Permission changes needed"
        sudo chown $USER -R /var/lib/vnstat/*
        sudo chgrp $USER -R /var/lib/vnstat/*
        sudo chown $USER -R /var/lib/vnstat
        sudo chgrp $USER -R /var/lib/vnstat
    else
        echo "No permission changes needed"
    fi
fi

# if we are in the Docker CentOS droplets, it seems that the "automatic selection" is fine, so ignore this section
if [ "$(linux_distro)" != '"centos"' ] && [ "$(linux_distro)" != '"rhel"' ]
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

if [ "$(linux_distro)" = 'debian' ] || [ "$(linux_distro)" = 'ubuntu' ] || [ "$(linux_distro)" = '"rhel"' ]
then
    vnstat -u -i $NEW_INTERFACE
elif [ "$(linux_distro)" = 'centos' ]
then
    vnstat -add -i $NEW_INTERFACE
fi

# 2020-04-28 - ZLH - Decided it would be better to just git clone the repo, so this is unnecessary now
# wget -O stats.sh https://raw.USERcontent.com/ZLHysong/getStats/master/stats.sh
# wget -O getAverages.py https://raw.USERcontent.com/ZLHysong/getStats/master/getAverages.py


# This currently assumes no other cronjobs are runnin on the current system
# TODO - Add a proper check here to verify if the specific cronjobs we want to run are added or not
echo "Cronjobs not running. Adding now..."
echo "Cronjobs added, please confirm they were added properly, using the right user and only exist once."
cronjob="*/15 * * * * env USER=$LOGNAME /home/$USER/getStats/stats.sh"
(crontab -u $USER -l; echo "$cronjob" ) | crontab -u $USER -
cronjob2="00 11 * * 5  env USER=$LOGNAME /usr/bin/python3 /home/$USER/getStats/getAverages.py /home/$USER/getStats/log.txt"
(crontab -u $USER -l; echo "$cronjob2" ) | crontab -u $USER -
